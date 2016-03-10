# Description
#   ...
#
# Configuration:
#   HUBOT_AUTH_ADMIN - A comma separate list of user IDs
#
# Commands:
#   hubot knock knock - Who's there?
#
# Notes:
# 

module.exports = (robot) ->

  robot.respond /knock knock/i, (msg) ->
    msg.reply "Who's there?"
