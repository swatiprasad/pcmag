class SubmissionsController < InheritedResources::Base
  before_filter :editors_only, :only => [:index]
  before_filter :editor_only, :only => [:edit, :destroy]

  def index
    @meetings = Meeting.all.sort_by(&:when).reverse
    @meetings_to_come = @meetings.select {|m| Time.now - m.when < 0}
    @meetings_gone_by = @meetings - @meetings_to_come
    @submissions = Submission.order("created_at DESC") - Packlet.all.collect(&:submission)
    index!
  end

  def show
    @submission = Submission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  def new
    if person_signed_in?
      @submission = Submission.new(:author_id => current_person.id)
    else
      @submission = Submission.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  def edit
    @submission = Submission.find(params[:id])
  end

  def create
    params[:submission][:author] = Person.find_or_create(params[:submission][:author])
    @submission = Submission.new(params[:submission])

    respond_to do |format|
      if @submission.save
        Notifications.new_submission(@submission).deliver
        format.html {
          flash[:notice] = "Thank you for helping make the world more beautiful! We look forward to reviewing it."
          if person_signed_in? and current_person.the_editor?
            redirect_to submissions_url
          elsif person_signed_in?
            redirect_to person_url(current_person)
          else
            redirect_to(root_url)
          end
        }
        format.xml  { render :xml => @submission, :status => :created, :location => @submission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params[:submission][:author] = Person.find_or_create(params[:submission][:author])
    @submission = Submission.find(params[:id])

    respond_to do |format|
      if @submission.update_attributes(params[:submission])
        format.html { redirect_to(@submission, :notice => 'Success!') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to(submissions_url) }
      format.xml  { head :ok }
    end
  end

protected
  
  def editor_and_owner_only
    @submission = Submission.find(params[:id])
    unless person_signed_in? and (current_person.the_editor? || current_person == @submission.author)
      flash[:notice] = "You didn't write that, and you're not the editor. Sorry!"
      redirect_to root_url
    end
  end
  def editors_and_owner_only
    @submission = Submission.find(params[:id])
    unless person_signed_in? and (current_person.editor? || current_person.name == @submission.author)
      flash[:notice] = "You didn't write that, and you're not the editor. Sorry!"
      redirect_to root_url
    end
  end
end
