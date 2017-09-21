#! bin/rails runner

id = 76

card = Card.find(id) rescue Card.find_by(title: id)
puts "#{card} (id=#{card.id})"
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
puts "==> 評価関数 <=="
card.effects.each do |effect|
  puts effect.evaluation_f
  game.players.each do |player|
    ge = GameEvaluator.new(game, player)
    puts "#{player}: #{effect.effect_factor(ge)}"
  end
end
