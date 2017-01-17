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

  describe '#first_name' do
    context 'nil name' do
      it 'should have a nil first_name' do
        activist = Activist.new

        expect(activist.first_name).not_to be
      end
    end

    context 'one name' do
      it 'should return the first name' do
        activist = Activist.new name: 'João'

        expect(activist.first_name).to eq('João')
      end
    end

    context 'two names or more' do
      it 'should return the first name' do
        activist = Activist.new name: 'João Silvério da Silva'

        expect(activist.first_name).to eq('João')
      end
    end
  end

  describe '#last_name' do
    context 'nil name' do
      it 'should have a nil last_name' do
        activist = Activist.new

        expect(activist.last_name).not_to be
      end
    end

    context 'one name' do
      it 'should have a nil last_name' do
        activist = Activist.new name: 'João'

        expect(activist.last_name).to eq('')
      end
    end

    context 'two names or more' do
      it 'should return the last name' do
        activist = Activist.new name: 'João Silvério da Silva'

        expect(activist.last_name).to eq('Silvério da Silva')
      end
    end
  end
end
