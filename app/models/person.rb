require 'digest/sha2'

class Person < ActiveRecord::Base
  devise :database_authenticatable, :omniauthable, :confirmable,
         :recoverable, :registerable, :rememberable, :trackable,
         :validatable

  attr_reader :password

  ENCRYPT = Digest::SHA256
  def self.find_by_email_and_password(email, password)
    person = self.find_by_email(email)
    if person and person.encrypted_password == ENCRYPT.hexdigest(password + "chrouiNt" + person.password_salt)
      return person
    end
  end

  has_many :ranks, :dependent => :destroy
  has_many :submissions, :foreign_key => 'author_id'
  has_many :attendees, :dependent => :destroy
  has_many :meetings, :through => :attendees

  validates_presence_of :first_name

  include Gravtastic
  gravtastic :size => 200, :default => "http://problemchildmag.com/images/children.png", :rating => 'R'

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def full_name
    "#{self.first_name} #{self.middle_name} #{self.last_name}"
  end

  def editor?
    rank = self.highest_rank
    rank = rank.rank_type if rank
    rank == 2 || rank == 3
  end

  def the_editor?
    rank = self.highest_rank
    rank = rank.rank_type if rank
    rank == 3
  end

  def the_coeditor?
    rank = self.highest_rank
    rank = rank.rank_type if rank
    rank == 2
  end

  def is_staff?
    self.ranks.where(:rank_end => nil).collect {|r| r.rank_type }.include? 1
  end

  def highest_rank
    self.ranks.where(:rank_end => nil).order("rank_type").last
  end

  def editorships
    self.ranks.where(:rank_type => 3).collect do |r|
      if r.rank_end
        "from #{r.rank_start.strftime("%e %b %Y")} until #{r.rank_end.strftime("%e %b %Y")}"
      else
        "since #{r.rank_start.strftime("%e %b %Y")}"
      end
    end
  end

  def coeditorships
    self.ranks.where(:rank_type => 2).collect do |r|
      if r.rank_end
        "from #{r.rank_start.strftime("%e %b %Y")} until #{r.rank_end.strftime("%e %b %Y")}"
      else
        "since #{r.rank_start.strftime("%e %b %Y")}"
      end
    end
  end

  def staffships
    self.ranks.where(:rank_type => 1).collect do |r|
      if r.rank_end
        "from #{r.rank_start.strftime("%e %b %Y")} until #{r.rank_end.strftime("%e %b %Y")}"
      else
        "since #{r.rank_start.strftime("%e %b %Y")}"
      end
    end
  end

  def current_ranks
    ranks = self.ranks.where(:rank_end => nil)
    ranks.collect do |r|
      rank = r.rank_type
      if rank == 1
        "Staff"
      elsif rank == 2
        "Coeditor"
      else rank == 3
        "Editor"
      end
    end
  end

  def can_enter_scores_for? meeting
    unless attendee = Attendee.find_by_person_id_and_meeting_id(self.id, meeting.id)
      false
    else
      if (scores = attendee.scores).empty?
        true
      else
        if scores.select {|s| s.entered_by_coeditor? }.empty?
          true
        else
          false
        end
      end
    end
  end

  class << self
    def editors
      ranks = Rank.where(:rank_type => 2..3, :rank_end => nil)
      ranks = ranks.sort_by {|a| a.rank_type }
      ranks.collect {|r| r.person}
    end
    def editor
      rank = Rank.where(:rank_type => 3, :rank_end => nil).first
      rank.person if rank
    end
    def coeditor
      rank = Rank.where(:rank_type => 2, :rank_end => nil).first
      rank.person if rank
    end
    def chad
      chad = Person.find_by_email "chad.ostrowski@gmail.com"
    end
    def find_or_create formatted_name_and_email
      if formatted_name_and_email =~ /\A.+<.+>\Z/
        email = formatted_name_and_email.scan(/<.+>/).first.delete "<>"
        person = Person.find_by_email email
        # unless person
        #   names = formatted_name_and_email.scan(/.+</).first.gsub(/["<>[:cntrl:]]/, '').split(' ')
        #   first = names.delete_at(0)
        #   last = names.delete_at(names.length - 1) unless names.empty?
        #   middles = names.join(' ') unless names.empty?
        #   person = Person.create(
        #     :first_name => first, 
        #     :middle_name => middles, 
        #     :last_name => last, 
        #     :email => email
        #   )
        # end
      else
        person = nil
      end 
      person
    end
  end
end
