class UserAutocompeleteMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/^\/users\/autocomplete/}
  end

  def self.deal(hash)
    params = Rack::Request.new(hash[:env]).params
    limit = params["limit"].to_i
#    users = User.fetch_str_cache(params["q"],:limit=>limit)
    users = User.find(:all,:conditions=>"users.name like '#{params["q"]}%' or users.email like '#{params["q"]}%' ",:limit=>limit)

    users_str = users.map do |user|
      {:id=>user.id,:name=>user.name,:email=>user.email,:avatar=>user.logo.url(:tiny)}.to_json
    end*"\n"
    return [200, {"Content-Type" => "text/plain; charset=utf-8"}, [users_str]]
  end
end