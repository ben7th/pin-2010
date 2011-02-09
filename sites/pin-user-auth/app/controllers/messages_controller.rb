class MessagesController < ApplicationController
  before_filter :login_required

  before_filter :per_load
  def per_load
    @message = Message.find(params[:id]) if params[:id]
  end

  def index
    @message_proxy = MessageProxy.new(current_user)
    @message_hash = {}
    @message_proxy.users.each do |user|
      @message_hash[user] = @message_proxy.unread_message_count_from(user)
    end
  end

  def user_messages
    @message_proxy = MessageProxy.new(current_user)
    @user = User.find(params[:user_id])
    @messages = @message_proxy.messages_from(@user)
    @message_proxy.clear_unread_message_vector_cache(@user)
  end

  def new
    @receiver_email = User.find(params[:receiver_id]).email if params[:receiver_id]
    @message = Message.new
  end

  def create
    begin
      receiver_email = params[:message][:receiver_email]
      MessageProxy.send_message(current_user,receiver_email,params[:message][:content])
    rescue Exception=>ex
      flash[:error] = ex.message
      return redirect_to :action=>:new
    end
    redirect_to :action=>:index
  end
end
