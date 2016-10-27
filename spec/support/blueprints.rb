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
  bg_class { 'classe 1'}
  hidden { false }
  bg_image { 'icon.png' }
  name { 'test' }
  menu_hidden { true }
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

Match.blueprint do
  widget { Widget.make! }
  first_choice { 'first_choice' }
  second_choice { 'second_choice' }
  goal_image { 'goal_image_path' }
end

FormEntry.blueprint do
  widget { Widget.make! }
  fields { [].to_json }
end

Activist.blueprint do
  name { "Foo Bar" }
  email { "foo@bar.org" }
  phone { { ddd: "11", number: "999999999" }.to_s }
  document_number { "12345678909" }
end

ActivistPressure.blueprint do
  widget { Widget.make! }
  activist { Activist.make! }
  firstname { "Foo" }
  lastname { 'Bar' }
  mail { { cc: ["barfoo@foobar.com"], subject: "Foo Bar Subject!", body: "Foo Bar Body!" } }
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

PayableTransfer.blueprint do
  transfer_id { 12345 }
  transfer_status { 'transferred' }
  organization { Organization.make! }
  amount { 100 }
end

TemplateMobilization.blueprint do
  user { User.make! }
  name { "TemplateMobilization #{sn}" }
  color_scheme { 'minhasampa-scheme' }
  header_font { 'Sans Serif' }
  body_font { 'open-sans' }
  custom_domain { "mytemplatemobilization" }
  slug { "#{sn}-templatemobilization" }
  organization { Organization.make! city: "São Paulo #{sn}"}
end

TemplateBlock.blueprint do
  template_mobilization { TemplateMobilization.make! }
  bg_class { 'classe 2'}
  position { 1 }
  hidden { true }
  bg_image { 'icone.png' }
  name { 'template_block name' }
  menu_hidden { false }
end

TemplateWidget.blueprint do
  template_block { TemplateBlock.make! }
  sm_size { 10 }
  md_size { 15 }
  lg_size { 20 }
  kind { "content" }
  action_community { true }
  settings { {content: "My 12 columns widget"} }
end

