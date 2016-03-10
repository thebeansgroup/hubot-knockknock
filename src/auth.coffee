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

caminte = require('caminte')
Schema  = caminte.Schema
schema  = new Schema(redis_config.driver, redis_config)
default_date = new Date("0000-01-01T00:00:00Z")

# define models
WorkSession = schema.define('KnockKnock::Session',
  id:    { type: schema.String ,index: true }
  name:  { type: schema.String ,index: true }
  email: { type: schema.String ,index: true }
  start: { type: schema.Date, default: Date.now,index: true  }
  end:   { type: schema.Date, default: default_date, index: true }
  completed: { type: schema.Boolean, default: false, index: true }
)

WorkSession.beforeSave = (next) ->
  console.log this.end
  console.log default_date
  this.completed = if this.end == default_date then false else true
  next()




WorkSession.destroyAll -> console.log('destroyed')

module.exports = (robot) ->

  robot.respond /back/i, (msg) ->
    user = msg.message.user
    session = new WorkSession
      id: user.id
      name: user.name
      email: user.email_address
    session.save()
    msg.reply JSON.stringify(session)

  robot.respond /users/i, (msg) ->
    WorkSession.all (err, y) -> msg.reply JSON.stringify(y)
    sessions = WorkSession.find().where({ completed: false })
    sessions.run {}, (err, x) ->
      msg.reply JSON.stringify(x)

