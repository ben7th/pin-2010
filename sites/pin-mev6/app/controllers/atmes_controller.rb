class AtmesController <  ApplicationController
  before_filter :login_required,:only=>[:index]
  def index
    @atmes = current_user.atmes
  end

  def show
    user = User.find_by_name(params[:id])
    unless user.blank?
      return redirect_to "/users/#{user.id}"
    end
    render_status_page(404,"用户不存在")
  end
end
