#
# Deps
#

Url = require 'url'
nohm = require('nohm').Nohm
Redis = require('redis')
null_date = require('./null_date.coffee')

#
# Redis Details
#

redisUrl =   if process.env.REDISTOGO_URL?
               redisUrlEnv = 'REDISTOGO_URL'
               process.env.REDISTOGO_URL
             else if process.env.REDISCLOUD_URL?
               redisUrlEnv = 'REDISCLOUD_URL'
               process.env.REDISCLOUD_URL
             else if process.env.BOXEN_REDIS_URL?
               redisUrlEnv = 'BOXEN_REDIS_URL'
               process.env.BOXEN_REDIS_URL
             else if process.env.REDIS_URL?
               redisUrlEnv = 'REDIS_URL'
               process.env.REDIS_URL
             else
               'redis://localhost:6379'


info   = Url.parse redisUrl, true
redisClient = if info.auth then Redis.createClient(info.port, info.hostname, {no_ready_check: true}) else Redis.createClient(info.port, info.hostname)


if info.auth
  redisClient.auth info.auth.split(':')[1], (err) ->
    if err
      console.log 'hubot-knockknock: Failed to authenticate to Redis'
    else
      console.log 'hubot-knockknock: Successfully authenticated to Redis'



#
# Setup ORM
#

# redisClient = Redis.createClient(info.port, info.hostname)
nohm.setPrefix('KnockKnock')
redisClient.on "connect", ->
    nohm.setClient(redisClient)


#
# Define model
#

WorkSession = nohm.model('Session',
  properties: {
    id: { type: 'string', index: true }
    name: { type: 'string', index: true }
    email: { type: 'string', index: true }
    start: { type: 'timestamp', defaultValue: Date.now, index: true }
    end: { type: 'timestamp', defaultValue: null_date, index: true }
    invalid: { type: 'boolean', defaultValue: false, index: true }
  }
)

module.exports = WorkSession
