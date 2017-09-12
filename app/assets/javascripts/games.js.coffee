$ ->
  $('span.show_hand').on 'click', ->
    $(this).parent().siblings('.hand_cards').toggle()

  $('span.show_influence_cards').on 'click', ->
    $(this).parents('.board_and_influence').children('.influence_cards').toggle()

  $('span#toggle_conquests').on 'click', ->
    $(this).siblings('.button_area').toggle()
    $(this).text(if $(this).text() == '[+]' then '[-]' else '[+]')

  randomBetween = (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  $('#game_assisting_command_submit').on 'click', ->
    command = $('#game_assisting_command_text').val()
    numMax = Number(command)
    num = randomBetween(1, numMax)
    message = num + ' picked out of 1 to ' + numMax
    $('#game_assisting_command_result').text(message)
