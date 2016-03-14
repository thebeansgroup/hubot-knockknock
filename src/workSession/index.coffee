#
# Setup
#
nohm = require('nohm').Nohm
null_date = require('./null_date.coffee')
WorkSession = require('./model.coffee')
moment = require('moment')

#
# Utils
#

utils =
  durations:
    day: 'day'
    today: 'day'
    week: 'isoweek'
    isoweek: 'isoweek'
    month: 'month'

  formatDuration: (duration) ->
    utils.durations[duration]

#
# Controller class
#

class Sessions
  startSession: (user, cb) ->
    this.findOpenSessionsByUser user, (err, sessions) ->
      if sessions.length
        session = sessions[0]
        session.p
          end: Date.now()
          invalid: true
        session.save (err) ->
          if(err)
            console.log('KnockKnock Error:', err)

      data =
        id: user.id
        name: user.name
        email: user.email_address
      session = nohm.factory('Session')
      session.p data
      session.save cb

  endSession: (user, cb) ->
    this.findOpenSessionsByUser user, (err, sessions) ->
      cb(true) if !sessions.length
      session = sessions[0]
      session.p
        end: Date.now()
      session.save cb


  deleteByID: (id) ->
    session = nohm.factory('Session')
    session.id = id
    session.remove()

  findDailySessionsByUser: (user, cb) ->
    this.findSessionsByUserAndDuration(user, 'day', cb)

  findWeeklySessionsByUser: (user, cb) ->
    this.findSessionsByUserAndDuration(user, 'isoweek', cb)

  findMonthlySessionsByUser: (user, cb) ->
    this.findSessionsByUserAndDuration(user, 'month', cb)

  findSessionsByUserAndDuration: (user, duration, cb) ->
    duration = utils.formatDuration(duration)
    min = moment().startOf(duration).format('x')
    max = moment().format('x')

    search =
      name: user.name
      start:
        min: min
        max: max

    WorkSession.findAndLoad search, cb


  findOpenSessionsByUser: (user, cb) ->
    WorkSession.findAndLoad {end: null_date, id: user.id}, cb

  findOpenSessions: (cb) ->
    WorkSession.findAndLoad {end: null_date}, cb

module.exports = Sessions
