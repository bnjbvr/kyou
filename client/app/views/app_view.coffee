request = require '../lib/request'
BaseView = require '../lib/base_view'

Mood = require '../models/mood'
DailyNote = require '../models/dailynote'
Moods = require '../collections/moods'

TrackerList = require './tracker_list'
BasicTrackerList = require './basic_tracker_list'

module.exports = class AppView extends BaseView

    el: 'body.application'
    template: require('./templates/home')

    events:
        'click #good-mood-btn': 'onGoodMoodClicked'
        'click #neutral-mood-btn': 'onNeutralMoodClicked'
        'click #bad-mood-btn': 'onBadMoodClicked'
        'click #add-tracker-btn': 'onTrackerButtonClicked'
        'change #datepicker': 'onDatePickerChanged'
        'blur #dailynote': 'onDailyNoteChanged'

    constructor: ->
        super
        @currentDate = moment()

    getRenderData: =>
        currentDate: @currentDate.format 'MM/DD/YYYY'

    afterRender: ->
        @data = {}
        @colors = {}
        $(window).on 'resize',  @redrawCharts

        @loadNote()
        @loadBaseAnalytics()

        @trackerList = new TrackerList()
        @$('#content').append @trackerList.$el
        @trackerList.render()
        @trackerList.collection.fetch()

        @basicTrackerList = new BasicTrackerList()
        @$('#content').append @basicTrackerList.$el
        @basicTrackerList.render()
        @basicTrackerList.collection.fetch()

        @$("#datepicker").datepicker maxDate: "+0D"
        @$("#datepicker").val @currentDate.format('LL'), trigger: false

    onDatePickerChanged: ->
        @currentDate = moment @$("#datepicker").val()
        @loadNote()
        @loadBaseAnalytics()
        @$("#datepicker").val @currentDate.format('LL'), trigger: false

    loadBaseAnalytics: ->
        @loadMood()
        @getAnalytics "moods", 'steelblue'
        @basicTrackerList.reloadAll() if @trackerList?
        @trackerList.reloadAll() if @trackerList?

    onGoodMoodClicked: -> @updateMood 'good'
    onNeutralMoodClicked: -> @updateMood 'neutral'
    onBadMoodClicked: -> @updateMood 'bad'

    updateMood: (status) ->
        @$('#current-mood').html '&nbsp;'
        @$('#current-mood').spin 'tiny'
        Mood.updateDay @currentDate, status, (err, mood) =>
            if err
                @$('#current-mood').spin()
                alert "An error occured while saving data"
            else
                @$('#current-mood').spin()
                @$('#current-mood').html status
                @$('#moods-charts').html ''
                @$('#moods-y-axis').html ''
                @getAnalytics 'moods', 'steelblue'

    loadMood: ->
        Mood.getDay @currentDate, (err, mood) =>
            if err
                alert "An error occured while retrieving mood data"
            else if not mood?
                @$('#current-mood').html 'Set your mood for current day'
            else
                @$('#current-mood').html mood.get 'status'

    onDailyNoteChanged: (event) ->
        text = @$("#dailynote").val()
        DailyNote.updateDay @currentDate, text, (err, mood) =>
            if err
                alert "An error occured while saving note of the day"

    loadNote: ->
        DailyNote.getDay @currentDate, (err, dailynote) =>
            if err
                alert "An error occured while retrieving daily note data"
            else if not dailynote?
                @$('#dailynote').val null
            else
                @$('#dailynote').val dailynote.get 'text'

    getAnalytics: (dataType, color) ->
        @$("##{dataType}-charts").html ''
        @$("##{dataType}-y-axis").html ''
        $("##{dataType}").spin 'tiny'
        path = "#{dataType}/#{@currentDate.format 'YYYY-MM-DD'}"
        request.get path, (err, data) =>
            if err
                alert "An error occured while retrieving #{dataType} data"
            else
                $("##{dataType}").spin()
                width = $("##{dataType}").width() - 30
                chartId = "#{dataType}-charts"
                yAxisId = "#{dataType}-y-axis"
                @data[dataType] = data
                @colors[dataType] = color
                @drawCharts data, chartId, yAxisId, color, width


    redrawCharts: =>
        $('.chart').html null
        $('.y-axis').html null
        for dataType, data of @data
            width = $("##{dataType}").width() - 30
            chartId = "#{dataType}-charts"
            yAxisId = "#{dataType}-y-axis"
            color = @colors[dataType]
            @drawCharts data, chartId, yAxisId, color, width
        @trackerList.redrawAll()
        @basicTrackerList.redrawAll()
        true


    drawCharts: (data, chartId, yAxisId, color, width) ->
        graph = new Rickshaw.Graph(
            element: document.querySelector("##{chartId}")
            width: width - 40
            height: 300
            renderer: 'bar'
            series: [
                color: color
                data: data
            ]
        )

        x_axis = new Rickshaw.Graph.Axis.Time graph: graph
        y_axis = new Rickshaw.Graph.Axis.Y
             graph: graph
             orientation: 'left'
             tickFormat: Rickshaw.Fixtures.Number.formatKMBT
             element: document.getElementById(yAxisId)

        graph.render()

        hoverDetail = new Rickshaw.Graph.HoverDetail
            graph: graph,
            xFormatter: (x) ->
                moment(x * 1000).format 'MM/DD/YY'
            formatter: (series, x, y) ->
                Math.floor y

        graph


    onTrackerButtonClicked: ->
        name = $('#add-tracker-name').val()
        description = $('#add-tracker-description').val()

        if name.length > 0
            @trackerList.collection.create(
                    name: name,
                    description: description
                ,
                    success: ->
                    error: ->
                        alert 'A server error occured while saving your tracker'
            )
