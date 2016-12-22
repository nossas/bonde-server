require 'rails_helper'

RSpec.describe Activist, type: :model do
  it { should have_many :donations }
  it { should have_many :addresses }
  it { should have_many :credit_cards }

  it { should validate_presence_of :name }
  it { should validate_presence_of :email }

  it { should allow_value('lorem@lorem.com').for(:email) }
  it { should_not allow_value('[{"uid"=>"field-1478867526541-5", "kind"=>"text", "label"=>"Nome", "placeholder"=>"", "required"=>"true", "value"=>"lorem"}]').for(:email) }
  it { should allow_value('lorem ipsum dolor sit amet').for(:name) }
  it { should_not allow_value('[{"uid"=>"field-1478867526541-5", "kind"=>"text", "label"=>"Nome", "placeholder"=>"", "required"=>"true", "value"=>"lorem"}]').for(:name) }
end
