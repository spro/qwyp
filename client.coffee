shoe = require 'shoe'
es = require 'event-stream'
qs = require 'querystring'
h = require 'hyperscript'
$ = require './static/jquery.min.js'

stream = shoe '/sock'

addMessage = (msg, extra_class) ->
    $msg = $ h 'div.message',
        h('span.from', msg['from']),
        h('span.body', msg['body'])
    $msg.addClass extra_class if extra_class?
    $('#messages').append $msg
    updateMessages()

stream.pipe es.mapSync (data) ->
    msg = JSON.parse(data)
    addMessage(msg)

window.updateMessages = () ->
    if $('#messages').height() < $(window).height() - $('#chat form').height()
        $('#messages').css('position', 'absolute')
        $('#messages').css('bottom', 0)
    else
        $('#messages').css('position', 'static')
        $('body').animate({ scrollTop: $('#messages').height() })

$ ->
    name = qs.parse(location.search[1..])['name']
    if not name?
        $('#join').show()
        $('#chat').hide()
        $('#join form').on 'submit', (e) ->
            e.preventDefault()
            window.name = $('#join input').val()
            $('#join').hide()
            $('#chat').show()
    else
        window.name = name
        $('#join').hide()
        $('#chat').show()

    $('#chat form').on 'submit', (e) ->
        e.preventDefault()
        msg =
            body: $('#chat input').val()
            from: window.name
        stream.write JSON.stringify msg
        addMessage(msg, 'mine')
        $('#chat input').val('')

