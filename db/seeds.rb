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

%w[
].each do |age_level, color_name, title, effect, resource_names|
  age = Age.find_by(level: age_level)
  color = Color.find_by(name: color_name)
  card = Card.create!(age: age, color: color, title: title, effect: effect)
  resource_names.zip(%w[LT LB CB RB]) do |resource_name, position_abbr|
    next unless resource_name.present?
    resource = Resource.find_by(name_eng: resource_name)
    position = ResourcePosition.find_by(abbr: position_abbr)
    CardResource.create!(card: card, resource: resource, resource_position: position)
  end
end

[
  %w[文化 Culture あなたの領域に５つの色があり、それらがすべて右か上に展開されている場合、ただちにこの分野を制覇する。 ルネッサンス（４）の「発明」により制覇することもできる。],
  %w[技術 Technology あなたが１ターンの間に保存または得点したカードが合わせて６枚以上になった場合、ただちにこの分野を制覇する。（他のプレイヤーから譲渡されたカードや、あなたの手札や影響から交換されたカードは、この数に含まない。） 先史時代（１）の「石工」により制覇することもできる。],
  %w[外交 Diplomacy あなたが資源の「時間」１２以上生み出している場合、ただちにこの分野を制覇する。 中世（３）の「翻訳」により制覇することもできる。],
  %w[軍事 Military あなたが資源６種類のそれぞれを３つ以上生み出している場合、ただちにこの分野を制覇する。 古代（２）の「建築」により制覇することもできる。],
  %w[科学 Science あなたの５つのアクティブなカードの値がすべて[８]以上である場合、ただちにこの分野を制覇する。 大航海時代（５）の「天文学」により制覇することもできる。],
].each do |name, name_eng, condition, note|
  Category.create!(name: name, name_eng: name_eng, condition: condition, note: note)
end
