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
  u.password = 'foobar!!'
  u.first_name = 'Foo'
  u.last_name = 'Bar'
  u.admin = false
  u.skip_confirmation!
end

user_admin = User.find_or_create_by(email: 'admin_foo@bar.com') do |u|
  u.uid = 'admin_foo@bar.com'
  u.provider = 'email'
  u.password = 'foobar!!'
  u.first_name = 'admin Foo'
  u.last_name = 'Bar'
  u.admin = true
  u.skip_confirmation!
end

communities = Community.create([
  { name: "Minha Blumenau", city: "Blumenau" },
  { name: "Minha Campinas", city: "Campinas" },
  { name: "Minha Curitiba", city: "Curitiba" },
  { name: "Minha Garopaba", city: "Garopaba" },
  { name: "Minha Ouro Preto", city: "Ouro Preto" },
  { name: "Minha Porto Alegre", city: "Porto Alegre" },
  { name: "Meu Recife", city: "Recife" },
  { name: "Meu Rio", city: "Rio de Janeiro" },
  { name: "Minha Sampa", city: "São Paulo" },
  { name: "Nossas Cidades", city:"Nossas Cidades" },
  { name: "Nuestras Ciudades", city:"Nuestras Ciudades" },
  { name: "Our Cities", city:"Our Cities" },
  { name: "Minha Jampa", city:"João Pessoa" },
  { name: "Meu Oiapoque", city:"Oiapoque" },
  { name: "Mi Ciudad Mx", city:"Ciudad de México" },
  { name: "Caracas Mi Convive", city:"Caracas" },
  { name: "Redes ayuda", city:"Redes ayuda" },
  { name: "ASJ", city:"ASJ" },
  { name: "Jóvenes Contra la Violencia", city:"Jóvenes Contra la Violencia" },
  { name: "Corporación para el Desarrollo Regional", city:"Corporación para el Desarrollo Regional" },
  { name: "Fósforo", city:"Fósforo" },
  { name: "Enjambre digital", city:"Enjambre digital" },
  { name: "Casa de las Estrategias", city:"Casa de las Estrategias" }
])

communities.each do |c|
  CommunityUser.create([
    {  
      user_id: user.id,
      community_id: c.id,
      role: 1
    }
  ])
end

mobilizations = Mobilization.create([
  {
    name: 'Vamos limpar o tietê!',
    user: user_admin,
    goal: 'Um rio limpo para todos',
    color_scheme: 'minhasampa-scheme',
    header_font: 'ubuntu',
    body_font: 'open-sans',
    community_id: communities.select{|c|c.name=='Minha Sampa'}[0].id
  },
  {
    name: 'Save the Whales!',
    user: user_admin,
    goal: 'More whales, more happyness',
    color_scheme: 'meurio-scheme',
    header_font: 'ubuntu',
    body_font: 'open-sans',
    community_id: communities.select{|c|c.name=='Meu Rio'}[0].id
  }
])

mobilizations.each do |mob|
  block = Block.create mobilization: mob, bg_class: 'bg-1', position:1, name: 'Tô nessa'
  Widget.create block: block, kind: ['pressure', 'form'][mob.id % 2], sm_size: 1, md_size: 2, lg_size: 4
end