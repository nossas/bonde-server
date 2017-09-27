require 'rails_helper'
#class TagAnActivistOmaticFake
#  attr_accessor :activist, :widget, :created_at
#
#  include ::TagAnActivistOmatic
#
#  def reload
#  end
#end


RSpec.describe TagAnActivistOmatic do
  describe 'add_automatic_tags' do
    let(:activist) { create(:activist) }
    subject { create(:donation, activist: activist, widget: create(:widget)) }

    it do
      expect(subject.activist).to receive(:add_tag).with(
        subject.community.id,
        anything,
        subject.mobilization,
        subject.created_at
      ).and_call_original
      subject.add_automatic_tags

      #allow(community).to receive(:id).and_return(13)
      #allow(mobilization).to receive(:name).and_return("Let's create a better world, friends")
      #allow(subject.widget).to receive(:community).and_return(community)
      #allow(subject.widget).to receive(:mobilization).and_return(mobilization)
      #allow(subject.widget).to receive(:kind).and_return('form')

      #expect(subject.activist).to receive(:add_tag).with(13,"form_let-s-create-a-better-world-friends", anything, anything)
    end
  end
end