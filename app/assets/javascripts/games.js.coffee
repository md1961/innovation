$ ->
  $('span.show_hand').on 'click', ->
    $(this).parent().siblings('.hand_cards').toggle()

  $('span.show_influence_cards').on 'click', ->
    $(this).parents('.board_and_influence').children('.influence_cards').toggle()

  $('span#toggle_conquests').on 'click', ->
    $(this).siblings('.button_area').toggle()
