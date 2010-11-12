module MpmlAccordion
  def parse_accordion
    doc.css('mp|accordion').each do |accordion|
      accordion_inner_html = ""

      global_active_bgc = accordion["active_bgc"] || ""
      global_bgc = accordion["bgc"] || ""

      rename accordion,'div'
      accordion["class"] = "mpaccordion-bar"
      accordion.css('mp|accordion-item').each do |item|

        title = item["title"]
        content = item.inner_html
        open = item["open"] == "true" ? true : false
        bgc = item["bgc"]
        bgc = bgc.blank? ? global_bgc : bgc
        active_bgc = item["active_bgc"]
        active_bgc = active_bgc.blank? ? global_active_bgc : active_bgc

        data_active_bgc_str = active_bgc.blank? ? "" : "data-active-bgc='#{active_bgc}'"
        data_bgc_str = bgc.blank? ? "" : "data-bgc='#{bgc}'"

        active_bgc_str = active_bgc.blank? ? "" : "background-color:#{active_bgc};"
        bgc_str = bgc.blank? ? "" : "background-color:#{bgc};"
        bgc_style = open ? active_bgc_str : bgc_str

        open_class = open ? "open" : "close"
        accordion_inner_html << %`
        <div class="mpaccordion-toggler #{open_class}" style="#{bgc_style}" #{data_active_bgc_str} #{data_bgc_str} >
           #{title}
        </div>
      `
       height_style = open ? "" : "height:0px;"
       accordion_inner_html << %`
        <div class="mpaccordion-content" style="#{height_style}">
          #{content}
        </div>
      `
      end
      accordion.inner_html = accordion_inner_html
    end
  end
end