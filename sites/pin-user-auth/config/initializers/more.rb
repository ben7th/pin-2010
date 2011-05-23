
module More
  class Collection
    attr_reader :last_value,:result
    def initialize(result,last_value)
      @result,@last_value = result,last_value
    end

    def each(&block)
      @result.each do |item|
        block.call(item)
      end
    end
  end
  
  module ModelMore
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # more(5,:mode=>:desc,:attr=>:updated_at,:value=>time)
      def more(count,options)
        attr = options[:attr].to_s
        mode = options[:mode].to_s
        value = options[:value]

        raise ":mode 不合法" unless ["desc","asc"].include?(mode)
        order = "#{attr} #{mode}"

        operater = case mode
        when "desc" then "<"
        when "asc" then ">"
        else
          raise ":mode 不合法"
        end
        if value.is_a?(Time)
          conditions = "#{attr} #{operater} '#{value.utc.strftime("%Y-%m-%d %H:%M:%S")}'"
        else
          conditions = "#{attr} #{operater} #{value}"
        end
        result = find(:all,:conditions=>conditions,:order=>order,:limit=>count)
        last_value = result.last.send(options[:attr])
        More::Collection.new(result,last_value)
      end
    end
  end

  module ArrayMore
    # Array.more(5,:attr=>:updated_at,:value=>1306131388)
    def more(count,options)
      attr = options[:attr]
      value = options[:value]

      attrs = self.map{|item|item.send(attr)}
      index = attrs.index(value)

      if index.blank?
        result = []
        last_value = nil
      else
        result = self[index+1..index+count]
        last_value = result.last.send(attr)
      end
      More::Collection.new(result,last_value)
    end

    def _vector_more_ids(count,options)
      return self[0...count] if options[:vector].blank?

      vector = options[:vector].to_i
      index = self.index(vector)
      return [] if index.blank?
      
      self[index+1..index+count]
    end

    # (10,:vector=>2,:model=>Feed)
    def vector_more(count,options)
      ids = _vector_more_ids(count,options)

      result = ids.map{|id|options[:model].find_by_id(id)}.compact
      last_value = ids.last
      More::Collection.new(result,last_value)
    end
  end
end

class Array
  include More::ArrayMore
end

class ActiveRecord::Base
  include More::ModelMore
end
