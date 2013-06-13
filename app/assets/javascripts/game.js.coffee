# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# http://weblog.bocoup.com/using-datatransfer-with-jquery-events/
$.event.props.push('dataTransfer');
$.event.props.push('clientX');
$.event.props.push('clientY');

targets = null

randomInt = (max) ->
  Math.floor(Math.random() * max)

setupTargets = ->
  targets = [
    { name: "parsley", x: _.random(25, 400), y: _.random(25, 375) },
    { name: "asparagus", x: _.random(25, 400), y: _.random(25, 375) },
    { name: "ravioli", x: _.random(25, 400), y: _.random(25, 375) }
  ]
getTargets = -> targets

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

clearPlate = ->
  $("#plate").html("")

placeOutlines = ->
  _.each getTargets(), (target) ->
    outline = $("<div class='target #{target.name}-outline'>")
    outline.css("top", target.y)
    outline.css("left", target.x)

    $("#plate").append outline

hideOutlines = ->
  $("#plate .target").delay(500).fadeOut('slow')

gameOver = ->
  clearTimeout(ramsayTimer) if ramsayTimer

  $("#timer").hide()
  $("#action-button").off 'click'
  $("#action-button").text("Start Game")
  $("#action-button").on 'click', startGame

  $("#top-bar").slideDown()
  $(".bubble").text("You finished #{roundsComplete} rounds.")

startCountdown = (expiration) ->
  $('#timer').countdown('destroy')
  $('#timer').countdown(
    until: expiration, compact: true,
    format: 'MS', description: '',
    onExpiry: gameOver
  )

RAMSAY_QUOTES = {
  good: ["Just, just just, what do you want a @#$%&! medal?", "You think you're smart don't you?", "And how long have you been working as a professional chef?"]
  neutral: ["You're sweating in the @#$%&! food!", "Wake up and get it back together!", "You're pushing me to the @#$%&! limit big boy."]
  bad: ["SHUT IT DOWN! TURN IT OFF, YOU @#$%&!! STOP IT!", "Look at me. Let's be honest, you're done. You can't waste my time any longer!", "GET YOUR JACKET OFF AND GET OUT!"]
}

ramsayTimer = null

finishRound = ->
  clearTimeout(ramsayTimer) if ramsayTimer

  roundsComplete += 1
  max = getTargets().length * 100
  score = max - minDeduction()
  if (score > 200)
    message = _.shuffle(RAMSAY_QUOTES.good)[0]
    klass = "good"
    nextRound(5)
  else if (score > 100)
    message = _.shuffle(RAMSAY_QUOTES.neutral)[0]
    klass = "neutral"
    nextRound()
  else
    message = _.shuffle(RAMSAY_QUOTES.bad)[0]
    klass = "bad"
    stopClick = (e) -> e.preventDefault() ; false
    $("body").on 'mousedown', stopClick
    nextRound()

  $(".bubble").addClass(klass).text(message)
  $("#top-bar").slideDown()
  ramsayTimer = setTimeout ->
    ramsayTimer = null
    if stopClick
      $("body").off 'mousedown', stopClick
    $(".bubble").removeClass(klass)
    $("#top-bar").slideUp()
  , 3000

expiration = null

roundsComplete = null
startGame = ->
  roundsComplete = 0
  $("#top-bar").hide()
  $("#timer").show()
  $("#action-button").off 'click'
  $("#action-button").text("Done")
  $("#action-button").on 'click', finishRound

  seconds = 25
  now = new Date()
  expiration = new Date(now.getTime() + seconds * 1000);

  clearPlate()
  setupTargets()
  placeOutlines()
  startCountdown(expiration)

nextRound = (additionalTime) ->
  clearPlate()
  setupTargets()
  placeOutlines()

  if additionalTime?
    expiration = new Date(expiration.getTime() + additionalTime * 1000)
    startCountdown(expiration)


$ ->
  $("#plate").on "dragover", (e) ->
    e.preventDefault()
    false

  $("#action-button").on 'click', startGame

  # calculate the offset between the cursor and top-left
  # corner of an ingredient when dragging starts anywhere
  dragHandleOffset = null
  $("#station").on "dragstart", ".ingredient", (e) ->
    hideOutlines()
    containerOffset = $(@).offset()

    dragHandleOffset =
      x: e.clientX - containerOffset.left,
      y: e.clientY - containerOffset.top

  draggedIngredient = null
  $("#plate").on "dragstart", ".ingredient", (e) ->
    draggedIngredient = $(@)
    e.dataTransfer.effectAllowed = 'move'

  $("#mise-en-place .ingredient").on "dragstart", (e) ->
    draggedIngredient = $(@).clone()

    e.dataTransfer.effectAllowed = 'move'

  $("#plate").on "drop", (e) ->
    e.stopPropagation()

    plateOffset = $(@).offset()
    top = e.clientY - dragHandleOffset.y - plateOffset.top
    left = e.clientX - dragHandleOffset.x - plateOffset.left

    draggedIngredient.css("top", top)
    draggedIngredient.css("left", left)

    $(@).removeClass("over").append(draggedIngredient)
