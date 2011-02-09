require "thrift"
class NoteLucene
  class SearchFailureError<StandardError;end

  # 搜索所有版本中的内容
  # option包括
  # page 第几页
  # per_page 每页个数
  def self.search_paginate_full(query,option)
    begin
      Searcher.new(query,option).search_paged_result_full
    rescue Exception => ex
      raise SearchFailureError,"搜索服务出现异常，或者正在维护。#{ex}"
    end
  end

  def self.search_paginate_newest(query,option)
    begin
      Searcher.new(query,option).search_paged_result_newest
    rescue Exception => ex
      raise SearchFailureError,"搜索服务出现异常，或者正在维护。#{ex}"
    end
  end

  class Client
    def self.instance
      @@instance ||= begin
        transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
        protocol = Thrift::BinaryProtocol.new(transport)
        client = LuceneNotesService::Client.new(protocol)
        transport.open()
        client
      end
    end
  end

  class Searcher
    attr_reader :query,:pager
    
    def initialize(query,option={})
      @query = query
      @pager = Pager.new(option)
    end

    def search_paged_result_full
      # TODO 参数传递重复，java搜索结果中应包含分页信息以避免此问题
      xml = Client.instance.search_page_full(@query, @pager.start_index, @pager.per_page)
      LuceneSearchResult.new(xml,:pager=>@pager)
    end

    def search_paged_result_newest
      # TODO 参数传递重复，java搜索结果中应包含分页信息以避免此问题
      xml = Client.instance.search_page_newest(@query, @pager.start_index, @pager.per_page)
      LuceneSearchResult.new(xml,:pager=>@pager)
    end

    # 从所有版本中搜索指定条数的结果
    def search_result_full(results_count=10)
      xml = Client.instance.search_page_full(@query, 0, results_count)
      LuceneSearchResult.new(xml)
    end

    # 从最新版本中搜索指定条数的结果
    def search_result_newest(results_count=10)
      xml = Client.instance.search_page_newest(@query, 0, results_count)
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
    end

    class LuceneSearchItem
      attr_reader :nid,:note,:commit_id,:score,:content
      def initialize(json)
        @nid = json["path"].match(/\/root\/mindpin_base\/note_repo\/notes\/([^\/]*)\/[^\/]*/)[1]
        @note = Note.find_by_id(@nid)
        @commit_id = json["commit_id"]
        @score = json["score"]
        @content = json["highlight"]
      end

      def self.build_from_array(search_result_hash_array)
        search_result_hash_array.map do |item_hash|
          self.new(item_hash)
        end
      end
    end
  end

  # 增加索引
  def self.add_index(note)
      path = note.repository_path
      commit_id = note.grit_repo(true).commits.first.id
      Client.instance.index_with_commit_id(path,commit_id)
    rescue Thrift::TransportException => ex
      p ex
    rescue RuntimeError => ex
      p ex
  end

  # 删除索引
  def self.delete_index(note)
      path = note.repository_path
      Client.instance.delete_index(path)
    rescue Thrift::TransportException => ex
      p ex
    rescue RuntimeError => ex
      p ex
  end

  # 重建所有索引
  def self.create_index()
    Note.all.each do |note|
      next if note.private
      self.add_index(note)
    end
    true
    rescue Exception => ex
      p ex
      false
  end
    
end
