require 'spec_helper'

describe ApplicationHelper do
  describe "#error_messages" do
    context "when the available `resource` has errors" do
      it "should return error messages for the resource" do
        pending "need to figure out how to init_haml_helpers in the context of the helper" do
          sub = Submission.create
          helper.stub(:resource).and_return(sub)
          content = helper.error_messages
          content.should match(/div id='errorExplanation'/)
          content.should match(/li>\s*#{sub.errors.full_messages.first}/)
          content.should match(/li>\s*#{sub.errors.full_message.last}/)
        end
      end
    end

    context "when the available `resource` does not have errors" do
      it "returns nil" do
        sub = Submission.new :author_email => "who@me.net", :title => "smidgen"
        sub.should be_valid
        helper.stub(:resource).and_return(sub)
        helper.error_messages.should be_nil
      end
    end
  end
end
