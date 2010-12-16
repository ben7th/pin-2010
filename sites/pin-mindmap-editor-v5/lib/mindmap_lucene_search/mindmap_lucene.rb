require "thrift"
class MindmapLucene

  def self.parse_content(content)
    client = self.client
    client.parse_content(content)
  end

  def self.relative_mindmaps(query,count)
    self.search_page(query,0,count).items.map{|item|item.mindmap}
  end

  # page 第几页
  # per_page 每页个数
  def self.search_paginate(query,option)
    page = option[:page].to_i || 1
    per_page = 10

    start_index = page*per_page - per_page
    count = per_page

    xml = self.search_page_xml(query,start_index,count)
    LuceneSearchResult.new(xml,:page=>page,:per_page=>per_page) do |item,json|
      item.id = json["id"]
      item.mindmap = Mindmap.find_by_id(json["id"])
      item.title = json["title"]
      item.content = json["content"]
      item.score = json["score"]
    end
  end

  def self.search_page_xml(query,start_index=0,count=9)
    client = self.client
    client.search_page(query,start_index,count)
  end

  # 查找 所有相关的 mindmap
  def self.search(query)
    xml = self.search_xml(query)
    LuceneSearchResult.new(xml) do |item,json|
      item.id = json["id"]
      item.mindmap = Mindmap.find_by_id(json["id"])
      item.title = json["title"]
      item.content = json["content"]
      item.score = json["score"]
    end
  end

  # 查找 所有相关的 mindmap xml
  def self.search_xml(query)
    client = self.client
    client.search(query)
  end

  def self.index_all
    client = self.client
    client.index()
  end

  # 给一个导图创建索引
  def self.index_one_mindmap(mindmap_id)
    Thread.start do
      begin
        client = self.client
        client.index_one_mindmap(mindmap_id)
      rescue Thrift::TransportException => ex
        p ex
      rescue RuntimeError => ex
        p ex
      end
    end
  end

  # 删除一个导图的索引
  def delete_index(mindmap_id)
    Thread.start do
      begin
        client = self.client
        client.delete_index(mindmap_id)
      rescue Thrift::TransportException => ex
        p ex
      rescue RuntimeError => ex
        p ex
      end
    end
  end

  private
  def self.client
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9091))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = LuceneMindmapsService::Client.new(protocol)

    transport.open()

    client
  end

end
