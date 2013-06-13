# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# http://weblog.bocoup.com/using-datatransfer-with-jquery-events/
$.event.props.push('dataTransfer');
$.event.props.push('clientX');
$.event.props.push('clientY');

getTargets = ->
  [
    { name: "ravioli", x: 165, y: 155 },
    { name: "asparagus", x: 100, y: 270 },
    { name: "asparagus", x: 300, y: 300 }
  ]

distance = (coord1, coord2) ->
  xDist = coord2.x - coord1.x
  yDist = coord2.y - coord1.y
  Math.sqrt((xDist * xDist) + (yDist * yDist))

getIngredients = ->
  $plate = $("#plate")

  plateOffset = $plate.offset()
  ingredients = $plate.find(".ingredient")

  for ingredient in ingredients
    ingredientOffset = $(ingredient).offset()

    name: $(ingredient).attr("title")
    x: ingredientOffset.left - plateOffset.left
    y: ingredientOffset.top - plateOffset.top

minDeduction = (targets, ingredients) ->
  targets ?= getTargets()
  ingredients ?= getIngredients()

  if _.isEmpty(targets)
    return ingredients.length * 50

  target = targets[0]
  remainingTargets = targets.slice(1)

  viableIngredients = _.select ingredients, (ingredient) ->
    ingredient.name == target.name

  deductions = [100 + minDeduction(remainingTargets, ingredients)]
  unless _.isEmpty viableIngredients
    _.each viableIngredients, (ingredient) ->
      remainingIngredients = _.without(ingredients, ingredient)
      dist = distance(ingredient, target)
      deduction = dist + minDeduction(remainingTargets, remainingIngredients)
      deductions.push deduction

  _.min(deductions)

placeOutlines = ->
  _.each getTargets(), (target) ->
    outline = $("<div class='target #{target.name}-outline'>")
    outline.css("top", target.y)
    outline.css("left", target.x)

    $("#plate").append outline

hideOutlines = ->
  $("#plate .target").hide()

showOutlines = ->
  $("#plate .target").show()

$ ->
  $("#plate").on "dragover", (e) ->
    e.preventDefault()
    false

  placeOutlines()

  console.log $("#done")
  $("#done").on 'click', ->
    max = getTargets().length * 100
    score = max - minDeduction()
    alert("Your score is: " + score)

  # calculate the offset between the cursor and top-left
  # corner of an ingredient when dragging starts anywhere
  dragHandleOffset = null
  $("#station").on "dragstart", ".ingredient", (e) ->
    containerOffset = $(@).offset()

    dragHandleOffset =
      x: e.clientX - containerOffset.left,
      y: e.clientY - containerOffset.top

  draggedIngredient = null
  $("#plate").on "dragstart", ".ingredient", (e) ->
    draggedIngredient = $(@)
    e.dataTransfer.effectAllowed = 'move'

  $("#mise-en-place .ingredient").on "dragstart", (e) ->
    # var dragIcon = document.createElement('img');
    # dragIcon.src = 'logo.png';
    # dragIcon.width = 100;
    # e.dataTransfer.setDragImage(dragIcon, -10, -10);

    e.dataTransfer.effectAllowed = 'copy'
    draggedIngredient = $(@).clone()

  $("#plate").on "drop", (e) ->
    e.stopPropagation()

    plateOffset = $(@).offset()
    top = e.clientY - dragHandleOffset.y - plateOffset.top
    left = e.clientX - dragHandleOffset.x - plateOffset.left

    draggedIngredient.css("top", top)
    draggedIngredient.css("left", left)

    $(@).removeClass("over").append(draggedIngredient)
