# Description
#   ...
#
# Configuration:
#   HUBOT_AUTH_ADMIN - A comma separate list of user IDs
#
# Commands:
#   hubot back - sets you as at work
#   hubot afk - sets you to Away From Keyboard
#   hubot stats(?) - Lists what you’ve worked that day
#   hubot users - list who is at work
#   hubot  ? <today|week> - list when team have been at work
#   hubot  ? <today|week|month> [<user>] - report of team working habits. Admin only
#
# Notes:
# 

#
# Redis Details
#

Url = require "url"
redis_url = process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379'
info = Url.parse redis_url, true
redis_config = {
  driver: "redis"
  url: redis_url
  password: ''
}

#
# Setup ORM
#

nohm = require('nohm').Nohm
Redis = require('redis')
redisClient = Redis.createClient(info.port, info.hostname)
setTimeout(
  ->
    nohm.setClient(redisClient)
, 3000)
nohm.setPrefix('KnockKnock')

# define models
default_date = (new Date("2000-01-01T00:00:00Z")).getTime()

WorkSession = nohm.model('Session',
  properties: {
    id:    { type: 'string', index: true }
    name:  { type: 'string', index: true }
    email: { type: 'string', index: true }
    start: { type: 'timestamp', defaultValue: Date.now,index: true  }
    end:   { type: 'timestamp', defaultValue: default_date, index: true }
  }
)

# WorkSession.beforeSave = (next) ->
#   console.log this.end
#   console.log default_date
#   this.completed = if this.end == default_date then false else true
#   next()

class Sessions
  startSession: (user, cb)->
    session = new WorkSession
      id: user.id
      name: user.name
      email: user.email_address
    session.save cb

  endSession: (user, cb)->

  deleteByID: (id)->
    session = nohm.factory('Session')
    session.id = id
    session.remove()

  findOpenSessionsByUser: (user, cb)->
    WorkSession.find {end: default_date, id: user.id}, cb

  findOpenSessions: (cb)->
    WorkSession.find {end: default_date}, cb


sessionController = new Sessions()

module.exports = (robot) ->

  robot.respond /back/i, (msg) ->
    user = msg.message.user
    sessionController.startSession user, (err) ->
      if err
        msg.reply 'Recording error.'
      else 
        msg.reply 'Welcome back'

  robot.respond /users/i, (msg) ->
    sessionController.findOpenSessions (err, x) ->
      msg.reply JSON.stringify(x)

