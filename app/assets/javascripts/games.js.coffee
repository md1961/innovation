$ ->
  $('span.show_hand').on 'click', ->
    $(this).parent().siblings('.hand_cards').toggle()
