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

redis_url =  if process.env.REDISTOGO_URL?
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

info = Url.parse redis_url, true

info   = Url.parse redisUrl, true
redisClient = if info.auth then Redis.createClient(info.port, info.hostname, {no_ready_check: true}) else Redis.createClient(info.port, info.hostname)

#
# Setup ORM
#

# redisClient = Redis.createClient(info.port, info.hostname)
nohm.setPrefix('KnockKnock')
setTimeout(
  ->
    nohm.setClient(redisClient)
, 3000) # TODO: Obs


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
