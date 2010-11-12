# Methods added to this helper will be available to all templates in the application.
module WebSiteVisitHelper

  def pie_hash(order)
    hash = ActiveSupport::OrderedHash.new
    web_site_visits = (order=="time")? current_user.web_site_visits_by_time : current_user.web_site_visits_by_count
    web_site_visits.each do |wsv|
      web_site = wsv.web_site
      hash.merge!(web_site.domain=>wsv.count) if web_site
    end
    return hash
  end
  
  def pie_xml(hash)
    str = ''
    str << %`<chart caption='站点访问统计' xAxisName='域名' yAxisName='次数' numberSuffix='次'> `
    hash.each do |key,value|
      str << %` <set label='#{key}' value='#{value}' /> `
    end
    str << "</chart>"
    return str
  end

  def render_pie(order)
    %`
      <div id="chartContainer">loading...</div>
        <script type="text/javascript">
        var myChart = new FusionCharts( "/javascripts/views/fusion_charts/swf/Bar2D.swf","myChartId", "300", "300", "0", "1" );
        myChart.setDataXML("#{pie_xml(pie_hash(order))}");
        myChart.render("chartContainer");
      </script>
    `
  end

end
