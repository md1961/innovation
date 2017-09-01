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

%w[].each.with_index(1) do |name, level|
  Age.create!(level: level, name: name)
end

%w[].each do |name, rgb|
  Color.create!(name: name, rgb: rgb)
end

%w[].each do |name, name_eng, color_name|
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
