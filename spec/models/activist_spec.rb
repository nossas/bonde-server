require 'rails_helper'

RSpec.describe Activist, type: :model do
  it { should have_many :donations }
  it { should have_many :addresses }
  it { should have_many :credit_cards }
  it { should have_many :activist_tags }
  it { should have_many :form_entries }
  it { should have_many :activist_pressures }
  it { should have_many :activist_matches }

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

  describe '#update_from_' do
    let!(:community) { create :community }
    {
      'csv_file' => './spec/models/activist.csv',
      'csv_content' => %(name,email,phone,document_number,document_type
joe montana,joe.montana@nfl.com,12312312312,cpf
hanna montana,hanna.montana@disney.com,12312312413,cpf)
      }.each do |type, value|

      subject{ eval "Activist.update_from_#{type}('#{value}', #{community.id})"  }

      it 'sould return the records' do
        expect(subject.size).to eq 2
      end

      it 'sould all been saved' do
        expect(subject.map{|s| s.id}.select{|id| id != nil }.uniq.count).to eq(2)
      end
    end
  end

  describe '#update_from_' do

    let!(:community) { create :community }
    let!(:activist) { Activist.create name: 'Joe Mon', email:'joe.montana@nfl.com' }

    {
      'csv_file' => './spec/models/activist.csv',
      'csv_content' => %(name,email,phone,document_number,document_type
joe montana,joe.montana@nfl.com,12312312312,cpf
hanna montana,hanna.montana@disney.com,12312312413,cpf)
    }.each do |type, value|

      subject{ eval "Activist.update_from_#{type} '#{value}', #{community.id}"  }

      it 'sould return the records' do
        expect(subject.size).to eq 2
      end

      it 'pre-existent sould had been user' do
        expect(subject.map{|s| s.id}.select{|id| id != nil }.uniq).to include(activist.id)
      end

      it 'should update data' do
        expect(subject.map{|s| s.name}.uniq).to include('joe montana')
      end
    end
  end

  describe 'tag_list' do
    let!(:activist_tag) {create(:activist_tag)}
    let(:activist) { Activist.find activist_tag.activist_id }

    before do
      activist_tag.tag_list = 'politica, corrupcao'
      activist_tag.save!
    end

    it 'should return the correct list of tags' do
      community_id = activist_tag.community_id


      expect(activist.tag_list community_id).to include('corrupcao')
      expect(activist.tag_list community_id).to include('politica')
      expect((activist.tag_list community_id).size).to eq 2
    end
  end
end
