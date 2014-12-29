{Adapter, TextMessage} = require "../../hubot"
Asteroid = require 'asteroid'

class Nullchat extends Adapter
  send: (envelope, strings...) ->
    @asteroid.call 'message', message:str, roomId:envelope.room for str in strings

  emote: (envelope, strings...) ->
    @send envelope, "* #{str}" for str in strings

  reply: (envelope, strings...) ->
    strings = strings.map (s) -> "#{envelope.user.name}: #{s}"
    @send envelope, strings...

  run: ->
    self = @

    startTime = new Date().getTime()
    @asteroid = new Asteroid "localhost:3000"
    @asteroid.loginWithPassword "nullbot","nullbot"
    mesSub = @asteroid.subscribe 'messages',"HDobwNyPyJeqtHgNk", 10

    isReady = false
    mesSub.ready.then (arg) ->
       isReady = true

    messages = @asteroid.getCollection "messages"
    reactiveQuery = messages.reactiveQuery {}

    reactiveQuery.on "change", (id) ->
        if isReady
          newMessageQuery = messages.reactiveQuery {"_id":id}
          if newMessageQuery.result
            newMessage = newMessageQuery.result[0]
            if newMessage and newMessage.message
              user = self.robot.brain.userForId 1, name: 'Shell', room: newMessage.roomId
              text = new TextMessage(user, newMessage.message, newMessage._id)
              self.receive text

    self.emit 'connected'

exports.use = (robot) ->
  new Nullchat robot
