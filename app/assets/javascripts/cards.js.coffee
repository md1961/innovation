$ ->
  $('.card').children('.card_actions').hide()

  $('.card').hover(
    ->
      $(this).children('.card_actions').show()
    ->
      $(this).children('.card_actions').hide()
  )
