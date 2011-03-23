class PieLinksMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/users\/(.+)\/mindmaps\/pie_links/}
  end

  def self.deal(hash)
    begin
      url_match = hash[:url_match]
      user_id = url_match[1]

      user_name = User.find(user_id).name

      bar = Bar.new(80, '#1D50A3')
      bar.key("#{user_name}的导图", 12)
      
      mindmaps = Mindmap.find_all_by_user_id(user_id)
      mrtc = MindmapsRankTendencyChart.new(mindmaps)
      g = Graph.new
      g.title('导图趋势分布',"{font-size:13px; color: #111111;}")
      bar.data << mrtc.values
      g.data_sets << bar
      g.set_bg_color('#E9F1F4')
      
      g.set_x_axis_color('#323546','#EAECF8')
      g.set_y_axis_color('#323546','#EAECF8')
      
      g.set_x_labels(mrtc.keys)
      g.set_y_max(mrtc.values.max)
      g.set_y_label_steps(1)
      g.set_y_legend("RANK VALUE", 10, "#1D50A3")
      
      g.set_x_label_style(10,'#333333')
      g.set_y_label_style(10,'#333333')
      
      g.set_tool_tip("#{user_name} rank值为#x_label#的导图 共#val#个")

      return [200, {"Content-Type" => "text/html"}, [g.render]]
    rescue Exception => ex
      return [500, {"Content-Type" => "text/plain"}, [ex.backtrace*"\n"]]
    end

  end
end
