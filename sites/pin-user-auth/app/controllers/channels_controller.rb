class ChannelsController < ApplicationController

  before_filter :per_load
  def per_load
    @channel = Channel.find_by_id(params[:id]) if params[:id]
  end

  def create
    channel = Channel.new(:name=>params[:name],:creator_email=>current_user.email)
    if channel.save
      return render :json=>channel.to_json
    end
    render :status=>403, :json=>{:error=>get_flash_error(channel)}
  end

  def destroy
    if @channel.destroy
      return redirect_to "/#{current_user.id}/followings"
    end
  end

  def update
    if @channel.update_attributes(:name=>params[:name])
      return render :status=>200, :text=>"修改成功"
    end
  end

  def add
    ChannelContactOperationQueue.new.add_task(ChannelContactOperationQueue::ADD_OPERATION,@channel.id,params[:user_id])
    return render :status=>200,:text=>"操作完成"
  end

  def remove
    ChannelContactOperationQueue.new.add_task(ChannelContactOperationQueue::REMOVE_OPERATION,@channel.id,params[:user_id])
    return render :status=>200,:text=>"操作完成"
  end
end
