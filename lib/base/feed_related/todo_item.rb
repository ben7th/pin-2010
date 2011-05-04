class TodoItem < UserAuthAbstract
  belongs_to :todo
  validates_presence_of :todo
  validates_presence_of :content

  module TodoMethods
    def self.included(base)
      base.has_many :todo_items,:order=>"id desc"
    end

    def first_todo_item
      self.todo_items.first
    end

    def create_or_update_todo_item(content)
      ti = self.first_todo_item
      return TodoItem.create(:todo=>self,:content=>content) if ti.blank?
      ti.update_attribute(:content,content)
    end

    def remove_last_todo_item
      todo_item = self.todo_items.last
      todo_item.destroy if todo_item
    end
  end
end
