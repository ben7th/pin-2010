class FavoritesController < ApplicationController
  before_filter :per_load
  def create
    if @bug.favor(current_user)
      render_ui do |ui|
        ui.page << %`
          $("bug_#{@bug.id}").down("a.favorites").update("#{text_num('顶',@bug.favor_count)}")
          alert("操作成功，谢谢您的参与")
        `
      end
    else
      render_ui do |ui|
        ui.page << %`
          alert("对不起，24个小时内，只能投票一次")
        `
      end
    end
  end

  def per_load
    @bug = Bug.find(params[:bug_id]) if params[:bug_id]
  end
end
