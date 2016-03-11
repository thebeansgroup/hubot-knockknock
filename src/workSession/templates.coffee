#
# Setup
#
moment = require('moment')


#
# Templates class
#

class Templates

  openSessions: (sessions)->
    return "No users online :(" if !sessions.length
    str = []
    for session in sessions
      start = moment(session.p('start')).format('LT')
      str.push """
      *#{session.p('name')}* started at #{start}
      """
    str.join '\n'

  back:(err) ->
    return 'Oops, sorry that didn\'t work.' if err
    'Welcome back! ┬┴┬┴┤･ω･)ﾉ├┬┴┬┴'

  afk:(err) ->
    return 'Umm, have you even started?' if err
    '(∗ ･‿･)ﾉ'


module.exports = Templates
