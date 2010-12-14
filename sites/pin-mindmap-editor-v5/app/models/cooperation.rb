class Cooperation < ActiveRecord::Base

  READ = "read"
  WRITE = "write"

  belongs_to :mindmap
  belongs_to :user,:foreign_key=>"email",:primary_key=>"email"

  module MindmapMethods
    def add_write_cooperators
      User.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{WRITE}'",
        :joins=>"inner join cooperations on cooperations.email = users.email")
    end

    def add_read_cooperators
      User.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{READ}'",
        :joins=>"inner join cooperations on cooperations.email = users.email")
    end
  end

end
