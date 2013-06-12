# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#http://weblog.bocoup.com/using-datatransfer-with-jquery-events/
$.event.props.push('dataTransfer');

$ ->
  $(".ingredient").on "dragstart", ->

    console.log "draggin"

  $("#plate").on "dragenter", ->
    $(this).addClass("over")

  $("#plate").on "dragleave", ->
    $(this).removeClass("over")

  $("#plate").on "dragover", (e) ->
    if e.preventDefault
      e.preventDefault()

    e.dataTransfer.dropEffect = 'move'
    false

  $(".ingredient").on "dragstart", (e) ->
    # var dragIcon = document.createElement('img');
    # dragIcon.src = 'logo.png';
    # dragIcon.width = 100;
    # e.dataTransfer.setDragImage(dragIcon, -10, -10);

    console.log "start - original event: ", e.originalEvent

    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('html', $(this).html());
    e.dataTransfer.setData('startCoords', [e.originalEvent.clientX, e.originalEvent.clientY])

  $(".ingredient").on "dragend", ->
    console.log "drag end"

  $("#plate").on "drop", (e) ->
    if e.stopPropagation
      e.stopPropagation()

    content = e.dataTransfer.getData('html')
    startCoords = e.dataTransfer.getData('startCoords')

    ingredient = $("<div class='ingredient'>").html(content)

    offset = $(this).offset()
    console.log "offset: ", offset
    console.log "original event: ", e.originalEvent
    ingredient.css("top", e.originalEvent.clientY - offset.top)
    ingredient.css("left", e.originalEvent.clientX)

    $(this).removeClass("over").append(ingredient)
    console.log "drop", e.dataTransfer.getData('html');
