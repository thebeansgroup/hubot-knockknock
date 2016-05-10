#
# Setup
#
moment = require('moment')
null_date = require('../workSession/null_date.coffee')


utils =
  minsToHours: (mins) ->
    "#{(mins / 60).toFixed(2)} hours"

  sessionsToDates: (sessions) ->
    dates = {}
    for session in sessions
      date = moment(session.p('start')).format('Do MMMM YYYY')
      dates[date] = [] if not dates[date]
      dates[date].push(session)
    dates

 
#
# Templates class
#

class Templates

  dailyUserStats: (err, sessions) ->
    if @hasError(err, sessions)
      return @error(err, 'You\'re yet to start today!')

    str = []
    total = 0
    for session in sessions
      start = moment(session.p('start'))
      end_stamp = session.p('end')
      isValid = @invalidText(session.p('invalid'))
      end = moment( @getEndTimestamp(end_stamp) )
      diff = end.diff(start, 'minutes')
      hours = utils.minsToHours(diff)
      extras = "#{@isCompletedText(end_stamp)} (#{hours}) #{isValid}"
      total += diff
      str.push """
Started #{start.format('LT')} — #{end.format('LT')}#{extras}
      """
    finish = moment().add( ((60*7.5) - total) , 'minutes').calendar()
    str.push "*Total:* #{utils.minsToHours(total)}"
    str.push "*Finish:* #{finish}"
    str.join '\n'

  invalidText: (invalid) ->
    if invalid then ' _* Invalid - Not closed_' else ''

  isCompleted: (stamp) ->
    (stamp isnt null_date)

  isCompletedText: (stamp) ->
    if @isCompleted(stamp) then '' else ' ᒡ◯ᵔ◯ᒢ '

  getEndTimestamp: (stamp) ->
    isCompleted = @isCompleted(stamp)
    if isCompleted then stamp else Date.now()

  openSessions: (err, sessions) ->
    return @error(err, 'No users online :(') if @hasError(err, sessions)
    str = []
    for session in sessions
      start = moment(session.p('start')).format('LT')
      str.push """
      *#{session.p('name')}* started at #{start}
      """
    str.join '\n'

  back: (err) ->
    return @error(err) if err
    'Welcome back! ┬┴┬┴┤･ω･)ﾉ├┬┴┬┴'

  afk: (err) ->
    return 'Umm, have you even started?' if err
    '(∗ ･‿･)ﾉ'

  report: (err, sessions, name) ->
    return @error(err) if err
    dates = utils.sessionsToDates(sessions)
    str = ["*Report for #{name}*\n\n"]
    for date, sessions of dates
      str.push "*#{date}*"
      str.push this.dailyUserStats(null, sessions)
      str.push '\n'

    str.join '\n'

  hasError: (err, collection) ->
    err or !collection.length

  error: (err, msg = 'Oops, sorry that didn\'t work.') ->
    console.log('KnockKnock Error:', err)
    return msg

module.exports = Templates
