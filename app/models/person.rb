require 'digest/sha2'

class Person < ActiveRecord::Base
  attr_reader :password

  ENCRYPT = Digest::SHA256

  has_many :sessions, :dependent => :destroy
  has_many :ranks, :dependent => :destroy

  validates_uniqueness_of :email, :message => "has already been used by someone else"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    :on => :create
  validates_format_of :password, :with => /\A([\x20-\x7E]){6,}\Z/,
    :message => "must be at least 6 characters",
    :unless => :password_is_not_being_updated?
  validates_confirmation_of :password
  validates_presence_of :first_name

  after_save :make_editor_if_first_person
  after_save :flush_passwords

  def self.find_by_email_and_password(email, password)
    person = self.find_by_email(email)
    if person and person.encrypted_password == ENCRYPT.hexdigest(password + "chrouiNt" + person.salt)
      return person
    end
  end

  def password=(password)
    @password = password
    unless password_is_not_being_updated?
      self.salt = [Array.new(9){rand(256).chr}.join].pack('m').chomp
      self.encrypted_password = ENCRYPT.hexdigest(password + "chrouiNt" + self.salt)
    end
  end


  def make_editor_if_first_person
    if Person.current_editors.count == 0
      Rank.new(:person_id => self.id, :rank_type => 3, :rank_start => self.created_at).save
    end
  end


  # CONVENIENCES
  def name
    "#{self.first_name} #{self.last_name}"
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

  def highest_rank
    self.ranks.sort {|a,b| a.rank_type <=> b.rank_type }.last
  end

  class << self
    def current_editors
      ranks = Rank.find(:all, :conditions => "(rank_type=2 OR rank_type=3) AND rank_end IS NULL")
      ranks = ranks.sort_by {|a| a.rank_type }
      ranks.collect {|r| r.person.name }
    end
  end

private

  def flush_passwords
    @password = @password_confirmation = nil
  end

  def password_is_not_being_updated?
    self.id and self.password.blank?
  end
end