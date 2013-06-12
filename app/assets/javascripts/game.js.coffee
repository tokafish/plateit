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

  handleOffset = null

  $(".ingredient").on "dragstart", (e) ->
    # var dragIcon = document.createElement('img');
    # dragIcon.src = 'logo.png';
    # dragIcon.width = 100;
    # e.dataTransfer.setDragImage(dragIcon, -10, -10);

    ingredientOffset = $(this).offset()

    handleOffset = {
      x: e.originalEvent.clientX - ingredientOffset.left,
      y: e.originalEvent.clientY - ingredientOffset.top
    }

    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('html', $(this).html())

  $(".ingredient").on "dragend", ->
    console.log "drag end"

  $("#plate").on "drop", (e) ->
    if e.stopPropagation
      e.stopPropagation()

    content = e.dataTransfer.getData('html')

    ingredient = $("<div class='ingredient'>").html(content)

    plateOffset = $(this).offset()

    top = e.originalEvent.clientY - handleOffset.y - plateOffset.top
    left = e.originalEvent.clientX - handleOffset.x - plateOffset.left

    ingredient.css("top", top)
    ingredient.css("left", left)

    $(this).removeClass("over").append(ingredient)
