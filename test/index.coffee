#node.js specific includes
if module?.exports?
  global.xo = require(__dirname + '/../xo.js')
  expect = require("expect.js")
else
  expect = window.expect

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
