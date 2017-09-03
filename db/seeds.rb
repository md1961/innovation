# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# age               : level:integer name
# color             : name rgb
# resource          : name color:references image:binary
# card              : age:references color:references title effect image:binary
# resource_position : name abbr is_left:boolean is_right:boolean is_bottom:boolean
# card_resource     : card:references resource:references resource_position:references

%w[
  先史時代 古代 中世 ルネッサンス 大航海時代 啓蒙時代 産業革命 近代 宇宙時代 情報時代
].each.with_index(1) do |name, level|
  Age.create!(level: level, name: name)
end

[
  %w[赤 Red    #FF0000],
  %w[緑 Green  #00FF00],
  %w[青 Blue   #0000FF],
  %w[黄 Yellow #FFFF00],
  %w[紫 Purple #800080],
  %w[灰 Gray   #808080],
].each do |name, name_eng, rgb|
  Color.create!(name: name, name_eng: name_eng, rgb: rgb)
end

[
  %w[石   Stone       灰],
  %w[木   Woods       緑],
  %w[金属 Metal       黄],
  %w[電気 Electricity 紫],
  %w[工業 Industry    赤],
  %w[時間 Time        青],
].each do |name, name_eng, color_name|
  color = Color.find_by(name: color_name)
  Resource.create!(name: name, name_eng: name_eng, color: color)
end

ResourcePosition.create!(name: '左上', abbr: 'LT', is_left: true , is_right: false, is_bottom: false)
ResourcePosition.create!(name: '左下', abbr: 'LB', is_left: true , is_right: false, is_bottom: true )
ResourcePosition.create!(name: '下'  , abbr: 'CB', is_left: false, is_right: false, is_bottom: true )
ResourcePosition.create!(name: '右下', abbr: 'RB', is_left: false, is_right: true , is_bottom: true )

[
  %w[文化 Culture あなたの領域に５つの色があり、それらがすべて右か上に展開されている場合、ただちにこの分野を制覇する。 ルネッサンス（４）の「発明」により制覇することもできる。],
  %w[技術 Technology あなたが１ターンの間に保存または得点したカードが合わせて６枚以上になった場合、ただちにこの分野を制覇する。（他のプレイヤーから譲渡されたカードや、あなたの手札や影響から交換されたカードは、この数に含まない。） 先史時代（１）の「石工」により制覇することもできる。],
  %w[外交 Diplomacy あなたが資源の「時間」１２以上生み出している場合、ただちにこの分野を制覇する。 中世（３）の「翻訳」により制覇することもできる。],
  %w[軍事 Military あなたが資源６種類のそれぞれを３つ以上生み出している場合、ただちにこの分野を制覇する。 古代（２）の「建築」により制覇することもできる。],
  %w[科学 Science あなたの５つのアクティブなカードの値がすべて[8]以上である場合、ただちにこの分野を制覇する。 大航海時代（５）の「天文学」により制覇することもできる。],
].each do |name, name_eng, condition, note|
  Category.create!(name: name, name_eng: name_eng, condition: condition, note: note)
end

[
  [1, '緑', '車輪', [
    %w[石 true [1]を２枚引く。],
  ], %w[nil 石 石 石]],
  [1, '黄', '牧畜', [
    %w[石 true あなたの手札の最も低い値のカードを１枚場に出す。[1]を１枚引く。],
  ], %w[石 金属 nil 石]],
  [1, '黄', '石工', [
    %w[石 true あなたの手札にある「石」を生み出すカードを望む枚数場に出してよい。これにより４枚以上のカードを場に出した場合、「技術」の分野を制覇する。],
  ], %w[石 nil 石 石]],
  [1, '赤', '弓矢', [
    %w[石 false 要求する。[1]を一枚引け。その後、お前の手札の最も高いカードを１枚、我が手札に譲渡せよ。],
  ], %w[石 電気 nil 石]],
  [1, '青', '筆記', [
    %w[電気 true [2]を１枚引く。],
  ], %w[nil 電気 電気 金属]],
  [1, '青', '陶器', [
    %w[木 true あなたの手札を３枚まで再生してよい。そうした場合、再生したカードの枚数に等しい値のカードを１枚引いて得点する。],
    %w[木 true [1]を１枚引く。],
  ], %w[nil 木 木 木]],
  [1, '青', '道具', [
    %w[電気 true あなたの手札を３枚再生してよい。そうした場合、[3]を１枚引いて場に出す。],
    %w[電気 true あなたの手札の[3]を１枚再生してよい。そうした場合、[1]を３枚引く。],
  ], %w[nil 電気 電気 石]],
  [1, '紫', '神秘主義', [
    %w[石 true [1]を１枚引いて公開する。それがあなたの領域のいずれかのカードと同じ色の場合、それを場に出し、[1]を１枚引く。そうでない場合、それをあなたの手札に加える。],
  ], %w[nil 石 石 石]],
  [1, '緑', '衣服', [
    %w[木 true あなたの手札の、あなたの領域にあるどのカードとも異なる色のカードを１枚場に出す。],
    %w[木 true あなたの領域にあり他のプレイヤーの領域にない色１色につき、[1]を１枚引いて得点する。],
  ], %w[nil 金属 木 木]],
  [1, '緑', '帆走', [
    %w[金属 true [1]を１枚引いて場に出す。],
  ], %w[金属 金属 nil 木]],
  [1, '紫', '都市国家', [
    %w[金属 false 要求する。お前が「石」を４以上生み出している場合、「石」を生み出すアクティブなカードを１枚我が領域に譲渡せよ。そうした場合、[1]を１枚引け。],
  ], %w[nil 金属 金属 石]],
  [1, '赤', '金属加工', [
    %w[石 true [1]を１枚引いて公開する。それが「石」を生み出す場合、それを得点し、この教義を繰り返す。そうでない場合、それをあなたの手札に加える。],
  ], %w[石 石 nil 石]],
  [1, '赤', '櫂', [
    %w[石 false 要求する。お前の手札の「金属」を生み出すカードを１枚、我が影響に譲渡せよ。そうした場合、[1]を１枚引け。],
    %w[石 true 上記の優越型教義によりカードが譲渡されなかった場合、[1]を１枚引く。],
  ], %w[石 金属 nil 石]],
  [1, '紫', '法典', [
    %w[金属 true あなたの手札の、あなたの領域にあるいずれかのカードと同じ色のカードを１枚保存してよい。そうした場合、その色を左に展開してよい。],
  ], %w[nil 金属 金属 木]],
  [1, '黄', '農業', [
    %w[木 true あなたの手札を１枚再生してよい。そうした場合、再生したカードの値より１大きい値のカードを１枚引いて得点する。],
  ], %w[nil 木 木 木]],
  [2, '紫', '哲学', [
    %w[電気 true あなたの色の山を１つ、左に展開してよい。],
    %w[電気 true あなたの手札を１枚得点してよい。],
  ], %w[nil 電気 電気 電気]],
  [2, '緑', '地図作成', [
    %w[金属 false 要求する。お前の影響の[1]を１枚、我が影響に譲渡せよ。],
    %w[金属 true 上記の優越型教義によりカードが譲渡された場合、[1]を１枚引いて得点する。],
  ], %w[nil 金属 金属 石]],
  [2, '青', '数学', [
    %w[電気 true あなたの手札を１枚再生してよい。そうした場合、再生したカードの値より１大きい値のカードを１枚引いて場に出す。],
  ], %w[nil 電気 金属 電気]],
].each do |age_level, color_name, title, effects, resource_names|
  age = Age.find_by(level: Integer(age_level))
  raise "Unknown Age '#{age_level}' for Card '#{title}'" unless age
  color = Color.find_by(name: color_name)
  raise "Unknown Color '#{color_name}' for Card '#{title}'" unless color
  card = Card.create!(age: age, color: color, title: title)
  effects.each do |resource_name, is_for_all, content|
    resource = Resource.find_by(name: resource_name)
    raise "Unknown Resource '#{resource_name}' for Card '#{title}'" unless resource
    raise "Illegal boolean '#{is_for_all}' for Card '#{title}'" unless %w[true false].include?(is_for_all)
    card.effects.create!(resource: resource, is_for_all: is_for_all == 'true', content: content)
  end
  resource_names.zip(%w[LT LB CB RB]) do |resource_name, position_abbr|
    next if resource_name == 'nil'
    resource = Resource.find_by(name: resource_name)
    raise "Unknown Resource '#{resource_name}' for Card '#{title}'" unless resource
    position = ResourcePosition.find_by(abbr: position_abbr)
    card.card_resources.create!(resource: resource, position: position)
  end
end
