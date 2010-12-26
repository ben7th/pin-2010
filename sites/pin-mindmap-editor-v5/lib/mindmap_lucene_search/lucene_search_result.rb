
class LuceneSearchResult
  attr_reader :count,:time,:items,:total_count
  attr_reader :total_pages,:previous_page,:next_page,:current_page
  def initialize(xml,option = {},&block)
    json = Hash.from_xml(xml)
    @time = json["search_results"]["time"]
    @count = json["search_results"]["count"]
    @total_count = json["search_results"]["total_count"]

    srs = json["search_results"]["search_result"] ||= []
    srs = [srs] if srs.class != Array
    @items = LuceneSearchItem.build_from_array(srs,&block)

    # 设置分页需要的属性
    @total_pages = 1;@current_page = 1
    @previous_page = 1;@next_page = 1
    if option[:page] && option[:per_page]
      @total_pages = (@total_count.to_f / option[:per_page].to_i).ceil
      @current_page = option[:page]
      @previous_page = @current_page - 1
      @previous_page = nil if @previous_page <=0
      @next_page = @current_page + 1
      @next_page = nil if @next_page > @total_pages
    end
  end
  
  class LuceneSearchItem
    def initialize(json,&block)
      @attrs = {}
      block.call(self,json)
    end

    def self.build_from_array(srs,&block)
      srs.map do |item_hash|
        self.new(item_hash,&block)
      end
    end

    def method_missing(method_name,*args)
      mns = method_name.to_s
      ma = mns.match(/(.+)=/)
      if ma
        @attrs[ma[1]] = args.first
      else
        value = @attrs[mns]
        return value
      end
    end
    
  end
end

