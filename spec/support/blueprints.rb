# coding: utf-8
require 'machinist/active_record'

User.blueprint do
  first_name {"Firstname #{sn}"}
  last_name {"Lastname #{sn}"}
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
  community { Community.make! }
end

Block.blueprint do
  mobilization { Mobilization.make! }
  bg_class { 'classe 1'}
  hidden { false }
  bg_image { 'icon.png' }
  name { 'test - block #{sn}' }
  menu_hidden { true }
end

Widget.blueprint do
  block { Block.make! }
  sm_size { 12 }
  md_size { 12 }
  lg_size { 12 }
  kind { "content" }
  action_community { false }
  settings { {content: "My 12 columns widget", other: "#{sn}"} }
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

ActivistMatch.blueprint do
  activist { Activist.make! }
  match { Match.make! }
end

Donation.blueprint do
  widget { Widget.make!(kind: 'donation', mobilization: Mobilization.make!) }
  activist { Activist.make! }
  card_hash { "fake/card_hash_kefh2309r3hhskjdfh" }
  amount { 3000 }
  payment_method { "credit_card" }
  email { "#{sn}@trashmail.com" }
end

Community.blueprint do
  name { "Nossas Cidades #{sn}" }
  city { "Rio de Janeiro #{sn}" }
  description {"Description #{sn}"}
  image {'http://images.reboo.org/nossas.png'}
  recipient { Recipient.make! community: object }
  recipients { [object.recipient] }
end

PayableTransfer.blueprint do
  transfer_id { 12345 }
  transfer_status { 'transferred' }
  community { Community.make! }
  amount { 100 }
end

TemplateMobilization.blueprint do
  user { User.make! }
  name { "TemplateMobilization #{sn}" }
  goal { 'Change the world, make it better place' }
  color_scheme { 'minhasampa-scheme' }
  header_font { 'Sans Serif' }
  body_font { 'open-sans' }
  custom_domain { "mytemplatemobilization" }
  slug { "#{sn}-templatemobilization" }
  community { Community.make! city: "São Paulo #{sn}"}
end

TemplateBlock.blueprint do
  template_mobilization { TemplateMobilization.make! }
  bg_class { 'classe 2'}
  position { 1 }
  hidden { true }
  bg_image { 'icone.png' }
  name { "template_block #{sn}" }
  menu_hidden { false }
end

TemplateWidget.blueprint do
  template_block { TemplateBlock.make! }
  sm_size { 10 }
  md_size { 15 }
  lg_size { 20 }
  kind { "content" }
  action_community { true }
  settings { {content: "My 12 columns widget", other: "any #{sn}"} }
end

CommunityUser.blueprint do
  user {User.make!}
  community {Community.make!}
  role {1}
end

Recipient.blueprint do
  community { Community.make! }
  pagarme_recipient_id { 're_ci9bucss300h1zt6dvywufeqc' }
  recipient {
    {
        object: "recipient",
        id: "re_ci9bucss300h1zt6dvywufeqc",
        bank_account: {
            object: "bank_account",
            id: 4841,
            bank_code: "341",
            agencia: "0932",
            agencia_dv: "5",
            conta: "58054",
            conta_dv: "1",
            document_type: "cpf",
            document_number: "26268738888",
            legal_name: "API BANK ACCOUNT",
            charge_transfer_fees: false,
            date_created: "2015-03-19T15:40:51.000Z"
        },
        transfer_enabled: true,
        last_transfer: nil,
        transfer_interval: "weekly",
        transfer_day: 5,
        automatic_anticipation_enabled: true,
        anticipatable_volume_percentage: 85,
        date_created: "2015-05-05T21:41:48.000Z",
        date_updated: "2015-05-05T21:41:48.000Z"
    }
  }
end