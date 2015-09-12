# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(
  email: 'foo@bar.com',
  uid: 'foo@bar.com',
  provider: 'email',
  password: 'foobar',
  first_name: 'Foo',
  last_name: 'Bar',
  admin: true
)

user.confirm!

Mobilization.create(
  name: 'Save the Whales!',
  user: user,
  color_scheme: 'meurio-scheme',
  header_font: 'ubuntu',
  body_font: 'open-sans'
)
