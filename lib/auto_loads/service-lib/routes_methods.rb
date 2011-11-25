module RoutesMethods
  def match_single_route(map, path, controller, action, method)
    map.connect path,
      :controller => controller,
      :action     => action,
      :conditions => {:method=>method}
  end

  def _match_config_hash(map, config_hash, method)
    path = config_hash.keys[0]
    controller, action = config_hash.values[0].split('#')

    match_single_route map, path, controller, action, method
  end

  def match_get(map, config_hash)
    _match_config_hash map, config_hash, :get
  end

  def match_post(map, config_hash)
    _match_config_hash map, config_hash, :post
  end

  def match_delete(map, config_hash)
    _match_config_hash map, config_hash, :delete
  end

  def match_put(map, config_hash)
    _match_config_hash map, config_hash, :put
  end
end
