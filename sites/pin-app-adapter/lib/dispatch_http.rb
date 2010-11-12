module DispatchHttp
  def dispatch_http(url,path,port,request,method)
    hash = {
      :get=>Net::HTTP::Get,:post=>Net::HTTP::Post,
      :put=>Net::HTTP::Put,:delete=>Net::HTTP::Delete
    }
    req = hash[method].new(path)
    req["X_REQUESTED_WITH"] = 'XMLHttpRequest' if request.xhr?
    req["Content-Type"] = request.headers['CONTENT_TYPE']
    req.body = request.raw_post
    response = Net::HTTP.new(url,port).start {|http| http.request(req) }
    return response
  end
end