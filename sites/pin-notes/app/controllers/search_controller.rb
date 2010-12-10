class SearchController < ApplicationController
  def show
    require "thrift"
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = LuceneService::Client.new(protocol)

    transport.open()

    @results = client.search(params[:q])
    render :xml=>@results
  end

  def create_index
    require "thrift"
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = LuceneService::Client.new(protocol)

    transport.open()

    @result = client.index("/root/mindpin_base/note_repo/notes")
    render :text=>@result
  end

end