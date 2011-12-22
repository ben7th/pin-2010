class MindpinDouban
  class Event
    class << self
      # 根据 活动ID 获取活动信息
      # id  例如 10069638
      def get_by_id(id)
        m = get_mash_by_url("http://api.douban.com/event/#{id}?alt=json")
        m
      end

      # 获取城市的所有活动
      # city_name : 例如 beijing shanghai 等，都是城市拼音
      # type  : 可选 all, commonweal, drama, exhibition, film, music, others, party, salon, sports, travel
      def get_all_by_city(city_name,type="all",start_index="",max_results="")
        m = get_mash_by_url("http://api.douban.com/event/location/#{city_name}?alt=json&type=#{type}&max-results=#{max_results}&start-index=#{start_index}")
        m.entry
      end

      # 根据 关键词 和 城市名 搜索所有活动
      def search(q,city="all",start_index="",max_results="")
        m = get_mash_by_url("http://api.douban.com/events?alt=json&q=#{q}&location=#{city}&start-index=#{start_index}&max-results=#{max_results}")
        m.entry
      end

      private
      def get_mash_by_url(url)
        json = open(URI.escape(url)).read
        json.gsub!('"@scheme":',       '"scheme":')
        json.gsub!('"@term":',         '"term":')
        json.gsub!('"@id":',           '"id":')
        json.gsub!('"@endTime":',      '"end_time":')
        json.gsub!('"@startTime":',    '"start_time":')
        json.gsub!('"@rel":',          '"rel":')
        json.gsub!('"@href":',         '"href":')
        json.gsub!('"@name":',         '"name":')
        json.gsub!('"@valueString":',  '"value_string":')
        json.gsub!('"$t":',            '"t":')
        json.gsub!('"db:location":',   '"location":')
        json.gsub!('"db:attribute":',  '"attribute":')
        json.gsub!('"gd:when":',       '"when":')
        json.gsub!('"gd:where":',      '"where":')
        json.gsub!('"@xmlns:georss":', '"georss":')
        json.gsub!('"georss:point":',  '"point":')

        obj = ActiveSupport::JSON.decode(json)
        Hashie::Mash.new(obj)
      end

    end
  end
end
