# See https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#configure-your-test-suite for information

FactoryGirl.define do
  factory :mobilization, class: Mobilization do
    user
    sequence(:name) { |sn| "Mobilization #{sn}" }
    color_scheme  'meurio-scheme' 
    goal 'Make the world a better place' 
    header_font 'ubuntu' 
    body_font 'open-sans'
    custom_domain  "mymobilization" 
    sequence(:slug) { |sn| "#{sn}-mobilization" }
    community
  end

  factory :block, class: Block do
    mobilization
    bg_class { 'classe 1'}
    hidden { false }
    bg_image { 'icon.png' }
    name { 'test - block #{sn}' }
    menu_hidden { true }
  end

  factory :widget, class: Widget do
    block
    sm_size { 12 }
    md_size { 12 }
    lg_size { 12 }
    kind { "content" }
    action_community { false }
    sequence(:settings) {|sn| {content: "My 12 columns widget", other: "#{sn}"} }
  end

  factory :match, class: Match do
    widget
    first_choice { 'first_choice' }
    second_choice { 'second_choice' }
    goal_image { 'goal_image_path' }
  end

  factory :form_entry, class: FormEntry do
    widget
    fields { [
        {
          'uid': 'field-1448381355384-46', 
          'kind': 'text',
          'label': 'first name',
          'placeholder': 'Insira aqui seu primeiro nome',
          'required': 'true',
          'value': 'José'
        },
        {
          'uid': 'field-1448381377063-15',
          'kind': 'text',
          'label': 'last name',
          'placeholder': 'Insira aqui seu último sobrenome',
          'required': 'true',
          'value': 'manuel'
        },
        {
          'uid': 'field-1448381397174-71',
          'kind': 'email',
          'label': 'email',
          'placeholder': 'Insira aqui o seu email',
          'required': 'true',
          'value': 'zemane@naoexiste.com'
        }    
      ].to_json 
    }
  end

  factory :activist_pressure, class: ActivistPressure do
    widget
    activist
    firstname { "Foo" }
    lastname { 'Bar' }
    mail { { cc: ["barfoo@foobar.com"], subject: "Foo Bar Subject!", body: "Foo Bar Body!" } }
  end

  factory :activist_match, class: ActivistMatch do
    activist
    match
  end

  factory :donation, class: Donation do
    widget kind: 'donation'
    activist
    card_hash { "fake/card_hash_kefh2309r3hhskjdfh" }
    amount { 3000 }
    payment_method { "credit_card" }
    sequence(:email) { |sn| "#{sn}@trashmail.com" }
  end

  factory :payable_transfer, class: PayableTransfer do
    transfer_id { 12345 }
    transfer_status { 'transferred' }
    community
    amount { 100 }
  end

  factory :template_mobilization , class: TemplateMobilization do
    user
    sequence(:name) { |sn| "TemplateMobilization #{sn}" }
    goal { 'Change the world, make it better place' }
    color_scheme { 'minhasampa-scheme' }
    header_font { 'Sans Serif' }
    body_font { 'open-sans' }
    custom_domain { "mytemplatemobilization" }
    sequence(:slug) { |sn| "#{sn}-templatemobilization" }
    community
  end

  factory :template_block, class: TemplateBlock do
    template_mobilization
    bg_class { 'classe 2'}
    position { 1 }
    hidden { true }
    bg_image { 'icone.png' }
    sequence(:name) { |sn| "template_block #{sn}" }
    menu_hidden { false }
  end

  factory :template_widget, class: TemplateWidget do
    template_block
    sm_size { 10 }
    md_size { 15 }
    lg_size { 20 }
    kind { "content" }
    action_community { true }
    sequence(:settings) { |sn| {content: "My 12 columns widget", other: "any #{sn}"} }
  end

  factory :community_user, class: CommunityUser do
    user
    community
    role {1}
  end

  factory :recipient , class: Recipient do
    community
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
end


# # USE EXAMPLES: 

# # Returns a User instance that's not saved
# user = build(:user)

# # Returns a saved User instance
# user = create(:user)

# # Returns a hash of attributes that can be used to build a User instance
# attrs = attributes_for(:user)

# # Returns an object with all defined attributes stubbed out
# stub = build_stubbed(:user)

# # Passing a block to any of the methods above will yield the return object
# create(:user) do |user|
#   user.posts.create(attributes_for(:post))
# end