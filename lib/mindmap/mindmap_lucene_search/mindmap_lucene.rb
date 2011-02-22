require "thrift"
class MindmapLucene

  class MindmapSearchFailureError<StandardError;end

  # 根据传入参数取得搜索结果
  # option包括
  # page 第几页
  # per_page 每页个数
  def self.search_paginate(query,option)
    begin
      Searcher.new(query,option).search_paged_result
    rescue Exception => ex
      raise MindmapSearchFailureError,"搜索服务出现异常，或者正在维护。#{ex}"
    end
  end

  class Client
    def self.instance
      @@instance ||= begin
        _transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9091))
        _protocol = Thrift::BinaryProtocol.new(_transport)
        _client = LuceneMindmapsService::Client.new(_protocol)
        _transport.open()
        _client
      end
    end
  end

  class Searcher
    attr_reader :query,:pager

    def initialize(query,option={})
      @query = query
      @pager = Pager.new(option)
    end

    def search_paged_result
      # TODO 参数传递重复，java搜索结果中应包含分页信息以避免此问题
      xml = Client.instance.search_page(@query, @pager.start_index, @pager.per_page)
      LuceneSearchResult.new(xml,:pager=>@pager)
    end

    # 搜索指定条数的结果
    def search_result(results_count=10)
      xml = Client.instance.search_page(@query, 0, results_count)
      LuceneSearchResult.new(xml)
    end

    class Pager
      attr_reader :page,:per_page,:start_index

      def initialize(option={})
        @page = (option[:page] || 1).to_i
        @per_page = (option[:per_page] || 6).to_i
        @start_index = (@page-1) * @per_page
      end
    end

    class LuceneSearchResult
      attr_reader :xml,:time,:count,:total_count,:items
      attr_reader :total_pages,:previous_page,:next_page,:current_page

      def initialize(xml, option={})
        @xml = xml
        @option = option
        
        @search_results = Hash.from_xml(xml)["search_results"]
        @time = @search_results["time"]
        @count = @search_results["count"]
        @total_count = @search_results["total_count"]

        build_paginate_params
      end

      def items
        @items ||=
          begin
            s_arr =  @search_results["search_result"] || []
            s_arr = [s_arr] if s_arr.class != Array
            LuceneSearchItem.build_from_array(s_arr)
          end
      end

      private
      def build_paginate_params
        # 设置分页需要的最小必要属性
        @total_pages = 1
        
        if pager = @option[:pager]
          @total_pages = (@total_count.to_f / pager.per_page).ceil

          _page = pager.page
          @current_page = _page
          
          @previous_page = _page - 1 if _page > 1
          @next_page     = _page + 1 if _page < @total_pages
        end
      end

      class LuceneSearchItem
        attr_reader :id,:mindmap,:title,:content,:score

        def initialize(hash)
          @id       = hash["id"]
          @mindmap  = Mindmap.find_by_id(hash["id"])
          @title    = hash["title"]
          @content  = hash["content"]
          @score    = hash["score"]

          @content = '' if @content == 'null'
        end

        def self.build_from_array(search_result_hash_array)
          search_result_hash_array.map do |item_hash|
            self.new(item_hash)
          end
        end
      end
      
    end
  end

  # 获取相关导图
  def self.similar_mindmaps_of(mindmap,maps_count=5)
    begin
      return [] if mindmap.low_value?

      query_str = mindmap.major_words*" "
      result = Searcher.new(query_str).search_result(maps_count + 1)

      maps = result.items.map{|i|i.mindmap}.compact
      maps = maps.select{|map|map != mindmap}[0...maps_count]
    rescue Exception => ex
      raise MindmapSearchFailureError,"搜索服务不可用。#{ex}"
    end
  end

  def self.similar_mindmaps_of_user(user,maps_count=5)
    begin
      this_user_mindmaps_count = user.mindmaps.count
      query_str = Mindmap.major_words_of_user(user,20)*" "
      result = Searcher.new(query_str).search_result(maps_count + this_user_mindmaps_count)

      user_id = user.id
      maps = result.items.map{|i|i.mindmap}.compact
      maps = maps.select{|map|map.user_id != user_id}[0...maps_count]
    rescue Exception => ex
      raise MindmapSearchFailureError,"搜索服务不可用。#{ex}"
    end
  end

  def self.split_words(text)
    begin
      Client.instance.parse_content(text||'')
    rescue Exception => ex
      raise MindmapSearchFailureError,"搜索服务不可用。#{ex}"
    end
  end

  # 给全部思维导图重建索引
  # 这个动作会清空原先的旧的索引
  def self.index_all
    begin
      Client.instance.index()
    rescue Exception => ex
      raise MindmapSearchFailureError,"搜索服务不可用。#{ex}"
    end
  end

  # 给一个导图创建或增量索引，异步工作
  def self.index_one_mindmap(mindmap_id)
    Thread.start do
      begin
        Client.instance.index_one_mindmap(mindmap_id)
      rescue Thrift::TransportException => ex
        p ex
      rescue RuntimeError => ex
        p ex
      end
    end
  end

  # 删除一个导图的索引，异步工作
  def self.delete_index(mindmap_id)
    Thread.start do
      begin
        Client.instance.delete_index(mindmap_id)
      rescue Thrift::TransportException => ex
        p ex
      rescue RuntimeError => ex
        p ex
      end
    end
  end

end
