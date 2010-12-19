class TendenciesController < ApplicationController
  def show
    @user = User.find(params[:user_id])

    @major_words = Mindmap.major_words_of_user(@user,10)
    @relative_mindmaps = Mindmap.relative_mindmaps_of_user(@user,10)

    @average_node_count = Mindmap.average_node_count_of_user(@user)
    @average_rank = Mindmap.average_rank_of_user(@user)
    @zero_weight_mindmaps_count = Mindmap.of_user_id(@user.id).is_zero_weight?(true).count

    @cooperate_edit_mindmaps_count = Mindmap.cooperate_edit_of_user(@user).count
    @cooperate_view_mindmaps_count = Mindmap.cooperate_view_of_user(@user).count
    @private_mindmaps_count = Mindmap.of_user_id(@user.id).privacy.count
    set_tabs_path "mindmaps/tabs"
  end
end
