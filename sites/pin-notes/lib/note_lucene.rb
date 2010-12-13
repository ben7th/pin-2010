require "thrift"
class NoteLucene
  # 所有版本搜索
  def self.all_search(query)
    xml = self.all_search_xml(query)
    json = Hash.from_xml(xml)
    SearchResult.new(json)
  end

  # 最新版本搜索
  def self.master_search(query)
    xml = self.master_search_xml(query)
    json = Hash.from_xml(xml)
    SearchResult.new(json)
  end

  # 最新版本搜索
  def self.master_search_xml(query)
    client = self.client
    client.new_search(query)
  end

  # 所有版本搜索
  def self.all_search_xml(query)
    client = self.client
    client.full_search(query)
  end

  # 增加索引
  def self.add_index(note)
      path = note.repository_path
      commit_id = note.grit_repo(true).commits.first.id
      client = self.client
      client.index_with_commit_id(path,commit_id)
    rescue Exception => ex
      p ex
  end

  # 删除索引
  def self.delete_index(note)
      path = note.repository_path
      client = self.client
      client.delete_index(path)
    rescue Exception => ex
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
      false
#    client = self.client
#    client.index("/root/mindpin_base/note_repo/notes")
  end


  private
  def self.client
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = LuceneService::Client.new(protocol)

    transport.open()

    client
  end

  class SearchResult
    attr_reader :count,:time,:items
    def initialize(json)
      @json = json
      @time = @json["search_results"]["time"]
      srs = @json["search_results"]["search_result"] ||= []
      srs = [srs] if srs.class != Array
      @count = srs.count
      @items = SearchItem.build_from_array(srs)
    end
  end

  class SearchItem
    attr_reader :nid,:note,:commit_id,:content
    def initialize(json)
      @nid = json["path"].match(/\/root\/mindpin_base\/note_repo\/notes\/([^\/]*)\/[^\/]*/)[1]
      @note = Note.find_by_id(@nid)
      @commit_id = json["commit_id"]
      @content = json["highlight"]
    end

    def self.build_from_array(arr)
      arr.map do |item_hash|
        self.new(item_hash)
      end
    end
    
  end
end
