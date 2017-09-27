require './app/models/concerns/tag_an_activist_omatic'
class TagAnActivistOmaticFake
  attr_accessor :activist, :widget

  include ::TagAnActivistOmatic

  def reload
  end
end


RSpec.describe TagAnActivistOmatic do
  subject { TagAnActivistOmaticFake.new }

  describe 'add_automatic_tags' do
    it do 
      subject.activist = spy(:activist)
      subject.widget = spy(:widget)
      mobilization = spy(:mobilization)
      community = spy(:community)

      allow(community).to receive(:id).and_return(13)
      allow(mobilization).to receive(:name).and_return("Let's create a better world, friends")
      allow(subject.widget).to receive(:community).and_return(community)
      allow(subject.widget).to receive(:mobilization).and_return(mobilization)
      allow(subject.widget).to receive(:kind).and_return('form')

      expect(subject.activist).to receive(:add_tag).with(13,"form_let-s-create-a-better-world-friends", mobilization, anything)

      subject.add_automatic_tags
    end
  end
end