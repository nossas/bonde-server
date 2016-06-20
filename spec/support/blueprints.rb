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
  organization { Organization.make! }
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
  action_community { false }
  settings { {content: "My 12 columns widget"} }
end

FormEntry.blueprint do
  widget { Widget.make! }
  fields { [].to_json }
end

Donation.blueprint do
  widget { Widget.make!(kind: 'donation', mobilization: Mobilization.make!) }
  card_hash { "fake/card_hash_kefh2309r3hhskjdfh" }
  amount { 3000 }
  payment_method { "credit_card" }
  email { "#{sn}@trashmail.com" }
end

Organization.blueprint do
  name { "Nossas Cidades #{sn}" }
  city { "Rio de Janeiro #{sn}" }
  pagarme_recipient_id { "re_fakerecipient" }
end
