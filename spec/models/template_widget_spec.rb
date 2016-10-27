require 'rails_helper'

RSpec.describe TemplateWidget, type: :model do
  it { should belong_to :template_block }
  it { should validate_presence_of :sm_size }
  it { should validate_presence_of :md_size }
  it { should validate_presence_of :lg_size }
  it { should validate_presence_of :kind }
  it { should validate_uniqueness_of :mailchimp_segment_id }

  describe "create_from" do
  	context "create an instance from Widget" do
      before do 
		@widget = Widget.make!
		@templateBlock = TemplateBlock.make!
		@templateWidget = TemplateWidget.create_from(@widget, @templateBlock)
  	  end

	  it "should have same template_block passed by" do 
	  	expect(@templateWidget.template_block).to eq(@templateBlock)
	  end

	  it "should have same settings value" do 
	  	expect(@templateWidget.settings).to eq(@widget.settings)
	  end

	  it "should have same kind value" do 
	  	expect(@templateWidget.kind).to eq(@widget.kind)
	  end

	  it "should have same sm_size value" do 
	  	expect(@templateWidget.sm_size).to eq(@widget.sm_size)
	  end

	  it "should have same md_size value" do 
	  	expect(@templateWidget.md_size).to eq(@widget.md_size)
	  end

	  it "should have same lg_size value" do 
	  	expect(@templateWidget.lg_size).to eq(@widget.lg_size)
	  end

	  it "should have same mailchimp_segment_id value" do 
	  	expect(@templateWidget.mailchimp_segment_id).to eq(@widget.mailchimp_segment_id)
	  end

	  it "should have same action_community value" do 
	  	expect(@templateWidget.action_community).to eq(@widget.action_community)
	  end

	  it "should have same exported_at value" do 
	  	expect(@templateWidget.exported_at).to eq(@widget.exported_at)
	  end
    end
  end
end
