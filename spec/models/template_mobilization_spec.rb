require 'rails_helper'

RSpec.describe TemplateMobilization, type: :model do
  it { should belong_to :user }
  it { should have_many :template_blocks }
  it { should have_many(:template_widgets).through(:template_blocks) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :name }
  it { should validate_length_of :twitter_share_text }

  describe "#create_from" do
  	context "create an instance from Mobilization" do
  		before do
  			@mobilization = Mobilization.make!
  			2.times do 
  				block = Block.make!(mobilization:@mobilization)
  				@mobilization.blocks << block
  				@mobilization.blocks.size.times do 
  					block.widgets << Widget.make!(block:block)
  				end
  			end
	  		@template = TemplateMobilization.create_from @mobilization
  		end

	  	it "should have the same name as original mobilization" do 
	  		expect(@template.name).to eq(@mobilization.name)
	  	end

	  	it "should have the same color_scheme as original mobilization" do 
	  		expect(@template.color_scheme).to eq(@mobilization.color_scheme)
	  	end

	  	it "should have the same facebook_share_title as original mobilization" do 
	  		expect(@template.facebook_share_title).to eq(@mobilization.facebook_share_title)
	  	end
	  	
	  	it "should have the same facebook_share_description as original mobilization" do 
	  		expect(@template.facebook_share_description).to eq(@mobilization.facebook_share_description)
	  	end
	  	
	  	it "should have the same header_font as original mobilization" do 
	  		expect(@template.header_font).to eq(@mobilization.header_font)
	  	end
	  	
	  	it "should have the same body_font as original mobilization" do 
	  		expect(@template.body_font).to eq(@mobilization.body_font)
	  	end
	  	
	  	it "should have the same facebook_share_image as original mobilization" do 
	  		expect(@template.facebook_share_image).to eq(@mobilization.facebook_share_image)
	  	end
	  	
	  	it "should have the same slug as original mobilization" do 
	  		expect(@template.slug).to eq(@mobilization.slug)
	  	end
	  	
	  	it "should have the same custom_domain as original mobilization" do 
	  		expect(@template.custom_domain).to eq(@mobilization.custom_domain)
	  	end

	  	it "should have the same twitter_share_text as original mobilization" do 
	  		expect(@template.twitter_share_text).to eq(@mobilization.twitter_share_text)
	  	end
	  	
	  	it "should have the same organization_id as original mobilization" do 
	  		expect(@template.organization_id).to eq(@mobilization.organization_id)
	  	end
  	end
  end
end
