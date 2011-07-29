class V2::IndexController < ApplicationController

  def chat
  end

  def chat_say
    Juggernaut.publish("chat",{:user=>{:name=>current_user.name},:message=>params[:message]})
    render :text=>200
  end
  
end