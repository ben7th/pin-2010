class PieLinksMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/users\/(.+)\/mindmaps\/pie_links/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    user_id = url_match[1]
    
    user_name = User.find(user_id).name
    
    bar = Bar.new(65, '#FFB019')
    bar.key("#{user_name}的导图", 12)

    mindmaps = Mindmap.find_all_by_user_id(user_id)
    mrtc = MindmapsRankTendencyChart.new(mindmaps)
    g = Graph.new
    g.title('导图趋势分布',"{font-size:13px; color: #ffffff;}")
    bar.data << mrtc.values
    g.data_sets << bar
    g.set_bg_color('#161621')
    
    g.set_x_axis_color('#3FBCEF','#1D2A63')
    g.set_y_axis_color('#3FBCEF','#1D2A63')

    g.set_x_labels(mrtc.keys)
    g.set_y_max(mrtc.values.max)
    g.set_y_label_steps(1)
    g.set_y_legend("RANK VALUE", 10, "#DF0024")

    g.set_x_label_style(10,'#ffffff')
    g.set_y_label_style(10,'#ffffff')

    g.set_tool_tip("#{user_name} rank值为#x_label#的导图 共#val#个")
    
    return [200, {"Content-Type" => "text/plain"}, [g.render]]
  end
end
