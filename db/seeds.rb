# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.find_or_create_by(email: 'foo@bar.com') do |u|
  u.uid = 'foo@bar.com'
  u.provider = 'email'
  u.password = 'foobar'
  u.first_name = 'Foo'
  u.last_name = 'Bar'
  u.admin = true
  u.confirm!
end

Mobilization.create(
  name: 'Save the Whales!',
  user: user,
  goal: 'More whales, more happyness',
  color_scheme: 'meurio-scheme',
  header_font: 'ubuntu',
  body_font: 'open-sans'
)
