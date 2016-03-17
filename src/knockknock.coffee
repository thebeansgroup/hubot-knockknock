# Description
#
# Commands:
#   hubot back - sets you as at work
#   hubot afk - sets you to Away From Keyboard
#   hubot stats - list of what you’ve worked that day
#   hubot users - list who is currently working
#   hubot knockknock <today|week|month> <user> Admin only
#

Sessions = require('./workSession')
Templates = require('./templates')
sessionController = new Sessions()
tmpl = new Templates()

module.exports = (robot) ->

  robot.respond /back/i, (msg) ->
    sessionController.startSession msg.message.user, (err) ->
      msg.reply tmpl.back(err)

  robot.respond /afk/i, (msg) ->
    sessionController.endSession msg.message.user, (err) ->
      msg.reply tmpl.afk(err)

  robot.respond /users/i, (msg) ->
    sessionController.findOpenSessions (err, sessions) ->
      msg.send tmpl.openSessions(err, sessions)

  robot.respond /stats/i, (msg) ->
    sessionController.findDailySessionsByUser msg.message.user,
      (err, sessions) ->
        msg.send tmpl.dailyUserStats(err, sessions)

  robot.respond /(?:knockknock|kk){1} (today|week|month) ([@.a-zA-Z]+)/i,
    (msg) ->
      if not robot.auth.isAdmin(msg.message.user)
        return msg.send('(ಠ_ಠ) Admin only.')

      duration = msg.match[1]
      user = msg.match[2].replace('@', '')
      sessionController.findSessionsByUserAndDuration {name: user}, duration,
        (err, sessions) ->
          msg.send tmpl.report(err, sessions, user)

  robot.router.post '/knockknock/end-open-sessions',
    sessionController.endOpenSessions

