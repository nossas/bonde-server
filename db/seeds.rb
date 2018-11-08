# coding: utf-8
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
end

user_admin = User.find_or_create_by(email: 'admin_foo@bar.com') do |u|
  u.uid = 'admin_foo@bar.com'
  u.provider = 'email'
  u.password = 'foobar!!'
  u.first_name = 'admin Foo'
  u.last_name = 'Bar'
  u.admin = true
end

communities = Community.create([
  { name: "Bonde", city:"Rio de Janeiro" },
  { name: "Nossas", city:"Rio de Janeiro" },
])

communities.each do |c|
  CommunityUser.create([
    {
      user_id: user.id,
      community_id: c.id,
      role: 1
    }
  ])
  CommunityUser.create([
    {
      user_id: user_admin.id,
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
    community_id: communities.select{|c|c.name=='Bonde'}[0].id
  },
  {
    name: 'Save the Whales!',
    user: user_admin,
    goal: 'More whales, more happyness',
    color_scheme: 'meurio-scheme',
    header_font: 'ubuntu',
    body_font: 'open-sans',
    community_id: communities.select{|c|c.name=='Bonde'}[0].id
  }
])

# run create all tags
connection = ActiveRecord::Base.connection()

sql = <<-EOL
  insert into tags ("name", "label") values ('user_meio-ambiente', 'Meio Ambiente') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_direitos-humanos', 'Direitos Humanos') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_segurança-publica', 'Segurança pública') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_mobilidade', 'Mobilidade') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_direito-das-mulheres', 'Direito das Mulheres') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_feminismo', 'Feminismo') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_participacao-social', 'Participação Social') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_educacao', 'Educação') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_transparencia', 'Transparência') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_direito-lgbtqi+', 'Direito LGBTQI+') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_direito-a-moradia', 'Direito à Moradia') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_combate-a-corrupção', 'Combate à Corrupção') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_combate-ao-racismo', 'Combate ao Racismo') ON CONFLICT (name) DO NOTHING;
  insert into tags ("name", "label") values ('user_saude-publica', 'Saúde Pública') ON CONFLICT (name) DO NOTHING;
  insert into configurations ("name", "value", "created_at", "updated_at") values ('jwt_secret', #{ENV['JWT_SECRET']}, now(), now()) ON CONFLICT (name) DO NOTHING;
EOL

sql.split(';').each do |s|
  connection.execute(s.strip) unless s.strip.empty?
end
