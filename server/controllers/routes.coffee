moods = require './moods'
dailynotes = require './dailynotes'
trackers = require './trackers'

module.exports =
    'trackerId': param: trackers.loadTracker
    'moods/:day':
        get: moods.all
    'moods/mood/:day':
        get: moods.day
        put: moods.updateDay
    'basic-trackers':
        get: trackers.allBasicTrackers
    'trackers':
        get: trackers.all
        post: trackers.create
    'trackers/:trackerId':
        put: trackers.update
        del: trackers.destroy
    'trackers/:trackerId/day/:day':
        get: trackers.day
        put: trackers.updateDayValue
    'trackers/:trackerId/amounts/:day':
        get: trackers.amounts
    'dailynotes/:day':
        get: dailynotes.day
        put: dailynotes.updateDay
