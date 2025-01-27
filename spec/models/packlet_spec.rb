require 'spec_helper'

describe Packlet do
  before do
    @meeting = Factory.create :meeting
    @submission = Factory.create :submission
    @packlet = @meeting.packlets.create :submission => @submission
  end


  it {
    should belong_to :meeting
    should belong_to :submission
    should have_many :scores

    should validate_presence_of :meeting_id
    should validate_presence_of :submission_id
  }

  it "only allows a submission to be reviewed once per meeting" do
    @p1 = Factory.create :packlet
    @p2 = Packlet.new :submission => @p1.submission, :meeting => @p1.meeting
    @p2.should_not be_valid
  end

  it "allows a submission to be reviewed at multiple meetings" do
    @p1 = Factory.create :packlet
    @m2 = Factory.create :meeting
    @p2 = Packlet.new :submission => @p1.submission, :meeting => @m2
    @p2.should be_valid

    @p2 = Factory.create :packlet
    @p2.meeting.should_not == @p1.meeting
    @p2.submission.should_not == @p1.submission

    @p3 = Packlet.new :submission => @p2.submission, :meeting => @p1.meeting
    @p3.should be_valid
  end

  it "does not allow a submission to be reviewed in multiple magazines" do
    magazine  = Factory.create :magazine
    magazine2 = Factory.create :magazine
    meeting   = Factory.create :meeting
    meeting2  = Factory.create :meeting
    meeting .update_attributes :magazine => magazine
    meeting2.update_attributes :magazine => magazine2
    submission = Factory.create :submission
    meeting.submissions << submission
    packlet = Packlet.create(
      :meeting => meeting2,
      :submission => submission
    )
    packlet.should_not be_valid
  end

  describe "#submission#draft?" do
    it "returns false, since a submission can only be scheduled after it's submitted" do
      @packlet.submission.draft?.should be_false
    end
  end

  describe "#create" do
    it "sets the packlet's submission to :queued if the meeting is in the future" do
      @packlet.submission.should be_queued
    end

    it "sets the packlet's submission to :reviewed if the meeting is in the past" do
      meeting = Meeting.create :datetime => 2.hours.from_now,
                               :question => "Jim?"
      packlet = meeting.packlets.create :submission => @submission
      packlet.submission.should be_reviewed
    end
  end

  describe "#destroy" do
    it "sets the packlet's submission to :submitted if this was its last packlet" do
      sub = @packlet.submission
      @packlet.destroy
      sub.should be_submitted
    end

    it "doesn't set the packlet's submission to :submitted if it _wasn't_ its last packlet" do
      sub = @packlet.submission
      meeting2 = Factory.create :meeting
      packlet2 = Packlet.create :meeting => meeting2, :submission => sub
      packlet2.destroy
      sub.should be_queued
    end

    it "accepts a {:current_person => blah} parameter without complaining" do
      person = Factory.build :person
      Person.should_receive(:editor).and_return("nope")
      @packlet.destroy :current_person => person
    end
  end
end
