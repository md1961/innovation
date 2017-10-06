$ ->
  $('div.board_cards_count_display').on 'click', ->
    $(this).parent().siblings('.board_cards_underneath').toggle()
    $(this).parent().siblings('.board_cards_expanded'  ).toggle()
