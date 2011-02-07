require 'lib/crypto'

class PeopleController < InheritedResources::Base
  before_filter :resource, :only => [:make_staff, :make_editor, :make_coeditor]
  before_filter :staff_only, :only => [:index]
  before_filter :editors_only, :only => [:destroy]
  auto_complete_for :person, [:first_name, :middle_name, :last_name, :email], :limit => 15 do |people|
    people.map {|person| "#{person.full_name}, #{person.email}" }.join "\n"
  end

  def show
    @person = Person.find params[:id]
    if person_signed_in? && (current_person.the_editor? || current_person == @person)
      @submissions = @person.submissions
      @drafts    = @submissions.where(:state => Submission.state(:draft)) if current_person == @person
      @submitted = @submissions.where :state => Submission.state(:submitted)
      @queued    = @submissions.where :state => Submission.state(:queued)
      @reviewed  = @submissions.where :state => Submission.state(:reviewed)
    end
  end

  #def create
    #@person = Person.new(params[:person])
    #if @person.save
      #if !session[:id]
        #flash[:notice] = "Welcome, #{@person.name}; you need to check your email to finish signing up."
        #redirect_to root_url
      #else
        #flash[:notice] = "#{@person.first_name} will get a welcome email soon."
        #redirect_to people_url
      #end
    #else
      #render :action => 'new'
    #end
  #end

  def update
    update! do |success, failure|
      failure.html { render :action => 'edit' }
    end
  end

  #def recover
    #person = Person.find_by_email(params[:recover_password][:email])
    #if person
      #Notifications.forgot_password(Crypto.encrypt("#{person.id}:#{person.salt}"), person.email).deliver
      #person.update_attributes(:verified => false)
      #flash[:notice] = "Please check your email."
      #redirect_to root_url
    #else
      #flash[:notice] = "Your account couldn't be found. Perhaps you entered the wrong email address?"
      #redirect_to help_people_path
    #end
  #end

  def make_staff
    promote(@person, 1)
  end

  def make_coeditor
    promote(@person, 2)
  end

  def make_editor
    promote(@person, 3)
  end

  def promote(person, to_rank)
    rank = Rank.new(:person => person, :rank_type => to_rank, :rank_start => Time.now)
    if rank.save
      flash[:notice] = "#{person.first_name} has been promoted!"
      redirect_to :action => :index
    else
      flash[:alert] = "There was an error promoting #{person.first_name}. Try again."
      redirect_to :action => :index
    end
  end

  def contact
    @to = Person.find(params[:contact_person][:to])
    @from = Person.find(params[:contact_person][:from])
    @subject = params[:contact_person][:subject]
    @message = params[:contact_person][:message]
    Communications.contact_person(@to, @from, @subject, @message).deliver
    flash[:notice] = "Your message has been sent!"
    redirect_to person_url(@to)
  end

protected

  def collection
    @people ||= end_of_association_chain.includes(:ranks).order('created_at')
  end

  def resource
    @person ||= Person.find(params[:id])
  end

  def editor?
    person_signed_in? && current_person.editor?
  end
end
