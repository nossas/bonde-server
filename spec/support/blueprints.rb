require 'machinist/active_record'

User.blueprint do
  email { "#{sn}@trashmail.com" }
  uid { email }
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
