class WebWeibo::ContactsController < ApplicationController
  layout 'fullscreen'
  before_filter :login_required
  before_filter :deal_params
  # 用于分页请求，请求第1页cursor传-1，
  # 在返回的结果中会得到next_cursor字段，表示下一页的cursor。
  # next_cursor为0表示已经到记录末尾。
  def deal_params
    @weibo_params = {
      :cursor    => params[:cursor],
      :page     => params[:page]
    }
  end

  #某用户的关注对象
  def friends
    @users = current_user.tsina_weibo.friends(@weibo_params.merge(:user_id=>params[:uid]))
  end

  #某用户的粉丝
  def followers
    @users = current_user.tsina_weibo.followers(@weibo_params.merge(:user_id=>params[:uid]))
  end
end
