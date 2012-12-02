#node.js specific includes
if module?.exports?
  global.xo = require(__dirname + '/../src')
  expect = require("expect.js")
  $ = require('jquery')
else
  expect = window.expect
  $ = window.$

describe "xo", () ->
  describe "#emit", () ->
    describe "with no listeners", () ->
      it "returns false", () ->
        expect(xo.emit("test")).to.eql false
    describe "with listeners", () ->
      before () ->
      it "returns true", () ->
        xo.on "test 1 2", (one, two, three) =>
          @one = one
          @two = two
          @three = three
        expect(xo.emit("test 1 2", 1, 2)).to.be true
      it "passes arguments to listener", () ->
        expect(@one).to.be 1
        expect(@two).to.be 2
        expect(@three).to.not.be.ok()
  describe "#on", () ->
    it "returns false", () ->
      expect(xo.on "whatever").to.be false

describe "xo.Agent", () ->
  describe "inline creation", () ->
    before () ->
      @agent = new xo.Agent
        hiCalled: false
        on:
          "hi": () ->
            @hiCalled = true
    it "receives events in own scope", () ->
      expect(@agent).to.be.ok()
      expect(@agent.hiCalled).to.equal false
      xo.emit "hi"
      expect(@agent.hiCalled).to.be true

  describe "subclassed instances", () ->
    class Listener extends xo.Agent
      message: false
      on:
        message: (msg) ->
          @message = msg

    listener = new Listener
    it "receive message", () ->
      expect(listener.message).to.be false
      xo.emit "message", "hello"
      expect(listener.message).to.be "hello"

    it "recieve multicast message", () ->
      listener2 = new Listener
      expect(listener2.message).to.be false
      expect(listener.message).to.be "hello"
      xo.emit "message", "bye"
      expect(listener2.message).to.be "bye"
      expect(listener.message).to.be "bye"

  describe "#destroy", () ->
    it "removes listeners", () ->
      agent = new xo.Agent
        callCount: 0
        on:
          "boom": () ->
            @callCount++
          "bang": () ->
            @callCount++
      xo.emit "boom"
      expect(agent.callCount).to.eql 1
      agent.destroy()
      xo.emit "boom"
      expect(agent.callCount).to.eql 1

describe "xo.View", ->
  describe "rendering", ->
    describe "with string $", ->
      view = new xo.View
        $: """
        <div><h1>works</h1></div>
        """
      it "creates element", ->
        expect(view.el.html()).to.eql "<h1>works</h1>"

    describe "with function $", ->
      view = new xo.View
        user:
          name: 'brian'
          email: 'test@example.com'
        $: ->
          """
          <ul>
            <li id="first">#{@user.name}</li>
            <li id="second">#{@user.email}</li>
          </ul>
          """

        it "renders in scope of view", ->
          el = $("<div></div>")
          el.append(view.el)
          expect(el.find("#first").text()).to.eql('brian')
          expect(el.find("#second").text()).to.eql('test@example.com')

  describe "event binding", ->
    clickCount = 0
    view = new xo.View
      $: "<div>hi</div>"
      bind:
        click: (e) -> clickCount++

    it "binds to element", ->
      view.el.click()
      expect(clickCount).to.eql 1

  describe "message listening", ->
    hitCount = 0
    view = new xo.View
      $: "<div>hi</div>"
      on:
        woo: ->
          hitCount++

    it "subscribes", ->
      expect(xo.emit "woo").to.eql true
      expect(hitCount).to.eql 1
      expect(xo.emit "woo").to.eql true
      expect(hitCount).to.eql 2

    it "unsubscribes", ->
      view.destroy()
      expect(xo.emit "woo").to.eql false
      expect(hitCount).to.eql 2

  describe "complex subscription", ->
    aCount = 0
    bCount = 0
    aView = new xo.View
      $: "<br />"
      on:
        zoom: -> aCount++
    class BView extends xo.View
      $: "<br />"
      on:
        zoom: -> bCount++

    it "works", ->
      expect(aCount).to.eql 0
      expect(xo.emit "zoom").to.eql true
      expect(aCount).to.eql 1
      expect(bCount).to.eql 0
      bView = new BView()
      expect(xo.emit "zoom").to.be true
      expect(aCount).to.eql 2
      expect(bCount).to.eql 1
      aView.destroy()
      expect(xo.emit "zoom").to.be true
      expect(aCount).to.eql 2
      expect(bCount).to.eql 2
      bView.destroy()
      xo.emit "zoom"
      expect(aCount).to.eql 2
      expect(bCount).to.eql 2

  describe "child views", ->
    hitCount = 0
    parent = new xo.View
      $: "<div id='parent'><div id='child-container'></div></div>"
      on:
        zug: -> hitCount++

    class Child extends xo.View
      $: -> "<div class='child'>#{@text}</div>"
      constructor: (@text) ->
        super()
      on:
        zug: -> hitCount++

    describe "append", ->
      it "adds child html", ->
        parent.append(new Child(1))
        expect(parent.el.find('.child').text()).to.eql 1

      it "adds a 2nd child", ->
        parent.append(new Child(2))
        children = parent.el.find('.child')
        expect(children.length).to.eql 2
        expect(children.first().next().text()).to.eql 2

      it "adds child to element", ->
        expect(parent.el.find('#child-container').find('.child').length).to.be 0
        parent.append("#child-container", new Child(3))
        expect(parent.el.find('#child-container').find('.child').length).to.be 1

    describe 'destroy', ->
      it "destroys children", ->
        expect(xo.emit "zug").to.be true
        expect(hitCount).to.be 4
        parent.destroy()
        expect(xo.emit "zug").to.be false
