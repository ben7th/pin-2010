class Organization < ActiveRecord::Base
  set_readonly(true)
  build_database_connection(CoreService::USER_AUTH)
  has_many :members
  
  def all_member_users
    members.map{|member| User.find_by_email(member.email)}.compact
  end

  def all_member_emails
    members.map{|member| member.email}
  end

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :organizations, :force => true do |t|
      t.string :name
      t.string :email
      t.string :kind
      t.timestamps
    end
  end

end