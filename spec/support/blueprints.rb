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
end

Block.blueprint do
  mobilization { Mobilization.make! }
end

Widget.blueprint do
  block { Block.make! }
  size { 12 }
  kind { "content" }
  settings { {content: "My 12 columns widget"} }
end
