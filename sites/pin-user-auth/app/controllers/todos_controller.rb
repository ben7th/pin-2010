class TodosController <  ApplicationController
  before_filter :per_load
  def per_load
    @todo = Todo.find(params[:id]) if params[:id]
  end
  
  before_filter :login_required
  before_filter :create_todo_filter,:only=>[:create]
  def create_todo_filter
    @feed = Feed.find(params[:feed_id])
    if current_user != @feed.creator
      render :text=>"503",:status=>503
    end
  end

  before_filter :destroy_todo_filter,:only=>[:destroy]
  def destroy_todo_filter
    @todo = Todo.find_by_id(params[:id])
    if current_user != @todo.creator
      render :text=>"503",:status=>503
    end
  end

  def create
    @todo = @feed.create_todo
    if @todo.valid?
      render_str = @template.render :partial=>'index/homepage/feeds/info_parts/info_todo',:locals=>{:feed=>@feed}
      return render :text=>render_str
    end
    render :text=>"503",:status=>503
  end

  def destroy
    @todo.destroy if @todo
    render :text=>"200",:status=>200
  end

  # 没有使用 ，routes 也没有配置
  #  def remove_last_todo
  #    @feed = Feed.find(params[:feed_id])
  #    @feed.remove_last_todo
  #    render_str = @template.render :partial=>'index/homepage/feeds/info_parts/info_todo',:locals=>{:feed=>@feed}
  #    return render :text=>render_str
  #  end

  def index
    return  _status_filter_todos if params[:status]
    return _assigned_todos
  end

  def move_to_first
    current_user.set_todo_to_first_of_assigned_todos(params[:id])
    render :status=>200,:text=>"操作成功"
  end

  def move_up
    current_user.set_todo_to_up_of_assigned_todos(params[:id])
    render :status=>200,:text=>"操作成功"
  end

  def move_down
    current_user.set_todo_to_down_of_assigned_todos(params[:id])
    render :status=>200,:text=>"操作成功"
  end

  def change_status
    status = params[:status]
    @todo.change_status_by(current_user,status)
    render :status=>200,:text=>"操作成功"
  end

  def assign
    @user = User.find(params[:user_id])
    @todo.add_executer(@user)
    render :status=>200,:text=>"操作成功"
  end

  def unassign
    @user = User.find(params[:user_id])
    @todo.remove_executer(@user)
    render :status=>200,:text=>"操作成功"
  end

  def update
  end

  def remove_last_todo_item
    @todo.remove_last_todo_item
    render :text=>200
  end

  def add_memo
    return (render :status=>503,:text=>"内容为空") if params[:memo].blank?
    if @todo.add_memo(current_user,params[:memo])
      str = @template.render :partial=>'feeds/todos_parts/todo',:locals=>{:t=>@todo}
      return render :text=>str
    end
    return render :status=>500,:text=>"error"
  end

  def clear_memo
    if @todo.clear_memo(current_user)
      return render :status=>200,:text=>"success"
    end
    return render :status=>500,:text=>"error"
  end

  private
  def _status_filter_todos
    @todos = current_user.status_todos(params[:status]).paginate(:per_page=>10,:page=>params[:page]||1)
    render :template=>"feeds/todos.haml"
  end

  def _assigned_todos
    @todos = current_user.assigned_todos.paginate(:per_page=>10,:page=>params[:page]||1)
    render :template=>"feeds/todos.haml"
  end

end
