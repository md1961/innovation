#! bin/rails runner

id = 66

card = Card.find(id)
puts "#{card} (id=#{id})"
puts card.effects.map { |effect| "* #{effect.content}" }.join("\n")

game = Game.last
puts "==> 必要条件 <=="
card.effects.each do |effect|
  puts effect.necessary_condition
  game.players.each do |player|
    ge = GameEvaluator.new(game, player)
    puts "#{player}: #{effect.executable?(ge)}"
  end
end
puts "==> 好条件 <=="
card.effects.each do |effect|
  puts effect.favorable_condition
  game.players.each do |player|
    ge = GameEvaluator.new(game, player)
    puts "#{player}: #{effect.favorable?(ge)}"
  end
end
