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
# Deps
#

Sessions = require('./workSession')
sessionController = new Sessions()
Templates = require('./workSession/templates.coffee')
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
      msg.send tmpl.openSessions(sessions)

