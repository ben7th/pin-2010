class TodoItemsController <  ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @todo = Todo.find(params[:todo_id]) if params[:todo_id]
  end

  def create
    if @todo.create_todo_item(params[:content])
      render_str = @template.render :partial=>'index/homepage/feeds/info_parts/info_todo',:locals=>{:feed=>@todo.feed}
      return render :text=>render_str
    end
    render :status=>503,:text=>503
  end

  def index
    render_str = @template.render :partial=>"todo/aj_todo_items",:locals=>{:todo_items=>@todo.todo_items}
    render :text=>render_str
  end

  def destroy
    @todo_item = TodoItem.find(params[:id])
    @todo_item.destroy if @todo_item.todo.creator == current_user
    render :text=>200
  end
end
