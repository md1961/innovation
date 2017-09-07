$ ->
  $('span.show_hand').on 'click', ->
    $(this).parent().siblings('.hand_cards').toggle()

  $('span.show_influence_cards').on 'click', ->
    $(this).parents('.board_and_influence').children('.influence_cards').toggle()

  $('span#switch_player').on 'click', ->
    alert('clicked!')
