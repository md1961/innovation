#! bin/rails runner

id = 105

card = Card.find(id)
puts "#{card} (id=#{id})"
puts card.effects.map { |effect| "* #{effect.content}" }.join("\n")

game = Game.last
card.effects.each do |effect|
  puts effect.condition
  game.players.each do |player|
    ge = GameEvaluator.new(game, player)
    puts "#{player}: #{effect.executable?(ge)}"
  end
end
