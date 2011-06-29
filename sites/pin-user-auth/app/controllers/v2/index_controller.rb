class V2::IndexController < V2::V2Controller

  def index
  end

  def do_activate
    ActivationCode.acitvate_user(params[:code],current_user)
    redirect_to :action=>:index
  end

  def chat
  end

  def chat_say
    Juggernaut.publish("chat",{:user=>{:name=>current_user.name},:message=>params[:message]})
    render :text=>200
  end
  
end