$ ->
  $('span.show_hand').on 'click', ->
    $(this).parent().siblings('.hand_cards').toggle()

  $('span.show_influence_cards').on 'click', ->
    $(this).parents('.board_and_influence').children('.influence_cards').toggle()

  $('span#NO_USE').on 'click', ->
    $('.board_and_influence:last').remove().insertBefore('.board_and_influence:first')

    $hand_visible = $('.hand_cards:visible')
    $hand_visible.hide()
    $next_hand = $hand_visible.parent().prev('.hand')
    if $next_hand.length > 0
      $next_hand.children('.hand_cards').show()
    else
      $hand_visible.parent().siblings('.hand:last').children('.hand_cards').show()
