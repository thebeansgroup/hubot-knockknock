#
# Deps
#

Url = require "url"
nohm = require('nohm').Nohm
Redis = require('redis')
null_date = require('./null_date.coffee')

#
# Redis Details
#

redis_url = process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379'
info = Url.parse redis_url, true

#
# Setup ORM
#

redisClient = Redis.createClient(info.port, info.hostname)
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
    id:       { type: 'string', index: true }
    name:     { type: 'string', index: true }
    email:    { type: 'string', index: true }
    start:    { type: 'timestamp', defaultValue: Date.now,index: true  }
    end:      { type: 'timestamp', defaultValue: null_date, index: true }
    invalid:  { type: 'boolean', defaultValue: false, index: true }
  }
)

module.exports = WorkSession
