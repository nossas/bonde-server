FactoryGirl.define do
  factory :invitation do
    community
    user
    email "mr.magoo@cartoon-cartoon.com"
    code "CA745146456456E3C"
    expires "2017-03-24 10:22:53"
    expired false
    role 2
  end
end
