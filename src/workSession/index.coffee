#
# Setup
#
nohm = require('nohm').Nohm
null_date = require('./null_date.coffee')
WorkSession = require('./model.coffee')

#
# Controller class
#

class Sessions
  startSession: (user, cb)->
    this.findOpenSessionsByUser user, (err, sessions)->
      if sessions.length
        session = sessions[0]
        session.p
          end: Date.now
          invalid: true
        session.save (err) -> console.log(err)

      data =
        id: user.id
        name: user.name
        email: user.email_address
      session = nohm.factory('Session')
      session.p data
      session.save cb

  endSession: (user, cb)->
    this.findOpenSessionsByUser user, (err, sessions)->
      cb(true) if !sessions.length
      session = sessions[0]
      session.p
        end: Date.now
      session.save cb


  deleteByID: (id)->
    session = nohm.factory('Session')
    session.id = id
    session.remove()

  findOpenSessionsByUser: (user, cb)->
    WorkSession.findAndLoad {end: null_date, id: user.id}, cb

  findOpenSessions: (cb)->
    WorkSession.findAndLoad {end: null_date}, cb

module.exports = Sessions
