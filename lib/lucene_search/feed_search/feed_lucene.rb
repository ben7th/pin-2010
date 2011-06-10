require "thrift"
class FeedLucene

  class FeedSearchFailureError<StandardError;end

  # 根据传入参数取得搜索结果
  # option包括
  # page 第几页
  # per_page 每页个数
  def self.search_paginate(query,option)
    begin
      Searcher.new(query,option).search_paged_result
    rescue Exception => ex
      puts ex.backtrace*"\n"
      raise FeedSearchFailureError,"搜索服务出现异常，或者正在维护。#{ex}"
    end
  end

  def self.search_paginate_by_user(query,user,option)
    begin
      Searcher.new(query,option).search_paged_result_by_user(user)
    rescue Exception => ex
      puts ex.backtrace*"\n"
      raise FeedSearchFailureError,"搜索服务出现异常，或者正在维护。#{ex}"
    end
  end

  class Client
    def self.connection
      _transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9092))
      _protocol = Thrift::BinaryProtocol.new(_transport)
      _client = LuceneFeedsService::Client.new(_protocol)
      _transport.open()
      yield(_client)
    ensure
      _transport.close()
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
      xml = Client.connection do |client|
        client.search_page(@query, @pager.start_index, @pager.per_page)
      end
      LuceneSearchResult.new(xml,:pager=>@pager)
    end

    def search_paged_result_by_user(user)
      # TODO 参数传递重复，java搜索结果中应包含分页信息以避免此问题
      xml = Client.connection do |client|
        client.search_page_by_user(@query, @pager.start_index, @pager.per_page,user.id)
      end
      LuceneSearchResult.new(xml,:pager=>@pager)
    end

    # 搜索指定条数的结果
    def search_result(results_count=10)
      xml = Client.connection do |client|
        client.search_page(@query, 0, results_count)
      end
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
        attr_reader :id,:feed,:content,:score,:detail

        def initialize(hash)
          @id       = hash["id"]
          @feed  =    Feed.find_by_id(@id)
          @content  = hash["content"]
          @score    = hash["score"]
          @detail   = hash["detail"]

          @content = '' if @content.strip == 'null'
          @detail = '' if @detail.strip == 'null'
        end

        def self.build_from_array(search_result_hash_array)
          search_result_hash_array.map do |item_hash|
            self.new(item_hash)
          end
        end
      end
      
    end
  end

  def self.index_one_feed(feed_id)
    Thread.start do
      begin
        # 等待 ruby 程序把数据写入数据库并提交后
        # 再调用 java 建立索引
        Client.connection do |client|
          client.index_one_feed(feed_id)
        end
      rescue Thrift::TransportException => ex
        p ex
      rescue RuntimeError => ex
        p ex
      end
    end
  end

  def self.index_all
    begin
      Client.connection do |client|
        client.index()
      end
    rescue Exception => ex
      raise FeedSearchFailureError,"搜索服务不可用。#{ex}"
    end
  end

  def self.delete_index(feed_id)
    Thread.start do
      begin
        Client.connection do |client|
          client.delete_index(feed_id)
        end
      rescue Thrift::TransportException => ex
        p ex
      rescue RuntimeError => ex
        p ex
      end
    end
  end

  # 查找相关的feed
  def self.similar_feeds_of(feed,feeds_count=5)
    begin
      query_str = feed.major_words*" "
      result = Searcher.new(query_str).search_result(feeds_count + 1)

      feeds = result.items.map{|i|i.feed}.compact
      feeds = feeds.select{|f|f != feed}[0...feeds_count]
    rescue Exception => ex
      raise FeedSearchFailureError,"搜索服务不可用。#{ex}"
    end
  end

  module FeedRevisionMethods
    def self.included(base)
      base.after_create :update_lucene_index_on_create
    end

    def update_lucene_index_on_create
      FeedLucene.index_one_feed(self.feed.id)
      return true
    end
  end

  module FeedMethods
    def self.included(base)
      base.after_update :update_lucene_index_on_update
      base.after_destroy :destroy_lucene_index_on_destroy
    end

    def destroy_lucene_index_on_destroy
      FeedLucene.delete_index(self.id)
      return true
    end

    def update_lucene_index_on_update
      return true if self.changes["hidden"].blank?
      FeedLucene.index_one_feed(self.id)
      return true
    end

    def major_words(words_count=5)
      KeywordsAnalyzer.new(self.content).major_words(words_count)
    rescue Exception => ex
      p ex
      return []
    end
  end

end
