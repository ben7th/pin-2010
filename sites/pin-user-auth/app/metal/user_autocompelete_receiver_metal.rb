class UserAutocompeleteReceiverMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/^\/users\/receiver_autocomplete/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(hash[:env]).params
    limit = params["limit"].to_i

    fans_id = self.current_user(env).fans.map{|u|u.id}

    users = User.find(:all,:conditions=>"id in (#{fans_id.join","}) and (users.name like '#{params["q"]}%' or users.email like '#{params["q"]}%' )",:limit=>limit)

    users_str = users.map do |user|
      {:id=>user.id,:name=>user.name,:email=>user.email,:avatar=>user.logo.url(:tiny)}.to_json
    end*"\n"
    return [200, {"Content-Type" => "text/plain; charset=utf-8"}, [users_str]]
  end
end