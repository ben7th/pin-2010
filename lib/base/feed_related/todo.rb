class Todo < UserAuthAbstract
  belongs_to :feed
  validates_presence_of :feed
  validates_presence_of :creator
  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id

  module FeedMethods
    def self.included(base)
      base.has_many :todos,:order=>"id desc"
    end

    def create_todo
      Todo.create(:feed=>self,:creator=>self.creator)
    end

    def remove_last_todo
      todo = self.todos.last
      todo.destroy if todo
    end

    def first_todo
      self.todos.first
    end

    def get_or_create_first_todo
      ft = self.first_todo
      if ft.blank?
        ft = self.create_todo
      end
      ft
    end
  end
  include TodoUser::TodoMethods
  include TodoItem::TodoMethods
end
