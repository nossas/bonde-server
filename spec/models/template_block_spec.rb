require 'rails_helper'

RSpec.describe TemplateBlock, type: :model do
  it { should belong_to :template_mobilization }
  it { should have_many :template_widgets }
  it { should validate_presence_of :template_mobilization_id }
  it { should validate_presence_of :position }
  it { should accept_nested_attributes_for :template_widgets }

  describe "create_from" do
  	context "create an instance from Block" do
      before do 
		@block = Block.make!
		3.times do 
		  @block.widgets << Widget.make!(block:@block)
		end

		@template = TemplateMobilization.make!
		@templateBlock = TemplateBlock.create_from(@block, @template)
  	  end

	  it "should have mobilization_template passed by" do 
	  	expect(@templateBlock.template_mobilization).to eq(@template)
	  end

	  it "should have same bg_class value" do 
	  	expect(@templateBlock.bg_class).to eq(@block.bg_class)
	  end
	  
	  it "should have same position value" do 
	  	expect(@templateBlock.position).to eq(@block.position)
	  end
	  
	  it "should have same hidden value" do 
	  	expect(@templateBlock.hidden).to eq(@block.hidden)
	  end
	  
	  it "should have same bg_image value" do 
	  	expect(@templateBlock.bg_image).to eq(@block.bg_image)
	  end
	  
	  it "should have same name value" do 
	  	expect(@templateBlock.name).to eq(@block.name)
	  end

	  it "should have same menu_hidden value" do 
	  	expect(@templateBlock.menu_hidden).to eq(@block.menu_hidden)
	  end
  	end
  end
end
