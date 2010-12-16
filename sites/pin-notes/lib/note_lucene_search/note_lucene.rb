require "thrift"
class NoteLucene
  # 所有版本搜索
  def self.search_full(query,start_index=0,count=10)
    xml = self.search_full_xml(query,start_index,count)
    json = Hash.from_xml(xml)
    SearchResult.new(json)
  end

  # 最新版本搜索
  def self.search_newest(query,start_index=0,count=10)
    xml = self.search_newest_xml(query,start_index,count)
    json = Hash.from_xml(xml)
    SearchResult.new(json)
  end

  # 最新版本搜索
  def self.search_newest_xml(query,start_index=0,count=10)
    client = self.client
    client.search_page_newest(query,start_index,count)
  end

  # 所有版本搜索
  def self.search_full_xml(query,start_index=0,count=10)
    client = self.client
    client.search_page_full(query,start_index,count)
  end

  def self.search_page_full(query,start_index,count)
    client = self.client
    client.search_page_full(query,start_index,count)
  end

  # 增加索引
  def self.add_index(note)
      path = note.repository_path
      commit_id = note.grit_repo(true).commits.first.id
      client = self.client
      client.index_with_commit_id(path,commit_id)
    rescue Thrift::TransportException => ex
      p ex
    rescue RuntimeError => ex
      p ex
  end

  # 删除索引
  def self.delete_index(note)
      path = note.repository_path
      client = self.client
      client.delete_index(path)
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
#    client = self.client
#    client.index("/root/mindpin_base/note_repo/notes")
  end


  private
  def self.client
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = LuceneNotesService::Client.new(protocol)

    transport.open()

    client
  end

  class SearchResult
    attr_reader :count,:time,:items,:total_count
    def initialize(json)
      @json = json
      @time = @json["search_results"]["time"]
      @count = @json["search_results"]["count"]
      @total_count = @json["search_results"]["total_count"]
      srs = @json["search_results"]["search_result"] ||= []
      srs = [srs] if srs.class != Array
      @items = SearchItem.build_from_array(srs)
    end
  end

  class SearchItem
    attr_reader :nid,:note,:commit_id,:score,:content
    def initialize(json)
      @nid = json["path"].match(/\/root\/mindpin_base\/note_repo\/notes\/([^\/]*)\/[^\/]*/)[1]
      @note = Note.find_by_id(@nid)
      @commit_id = json["commit_id"]
      @score = json["score"]
      @content = json["highlight"]
    end

    def self.build_from_array(arr)
      arr.map do |item_hash|
        self.new(item_hash)
      end
    end
    
  end
end
