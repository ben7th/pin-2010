class Member < ActiveRecord::Base
  set_readonly(true)
  build_database_connection(CoreService::USER_AUTH)

  module UserMethods
    def organizations
      org_ids = Member.find_all_by_email(self.email).map{|member|member.organization_id}
      org_ids.uniq!
      org_ids.map{|org_id|Organization.find_by_id(org_id)}.compact
    end
  end

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :members, :force => true do |t|
      t.integer :organization_id
      t.string :email
      t.timestamps
    end
  end
end