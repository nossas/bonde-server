require 'machinist/active_record'

User.blueprint do
  email { "#{sn}@trashmail.com" }
  uid { object.email }
  provider { "email" }
  password { "12345678" }
end

Mobilization.blueprint do
  user { User.make! }
  name { "Mobilization #{sn}" }
  color_scheme { 'meurio-scheme' }
  goal { 'Make the world a better place' }
  header_font { 'ubuntu' }
  body_font { 'open-sans' }
  custom_domain { "mymobilization" }
  slug { "#{sn}-mobilization" }
end

Block.blueprint do
  mobilization { Mobilization.make! }
end

Widget.blueprint do
  block { Block.make! }
  sm_size { 12 }
  md_size { 12 }
  lg_size { 12 }
  kind { "content" }
  settings { {content: "My 12 columns widget"} }
end

FormEntry.blueprint do
  widget { Widget.make! }
  fields { [].to_json }
end

Organization.blueprint do
  name { "Meu Rio #{sn}" }
  city { "Rio de Janeiro #{sn}" }
end
