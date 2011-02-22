class MemberBase < ActiveRecord::Base
  set_readonly(true)
  build_database_connection(CoreService::USER_AUTH,{:table_name=>"members"})

  KIND_COMMON = 'common'
  KIND_OWNER = 'owner'

  def username
    return '' if self.user.blank?
    self.user.name
  end

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :members, :force => true do |t|
      t.integer :organization_id
      t.string :email
      t.timestamps
    end
  end
end
