class Member < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :organization
  validates_presence_of :email
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  KIND_COMMON = 'common'
  KIND_OWNER = 'owner'

  def user
    User.find_by_email(email)
  end

end
