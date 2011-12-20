class MindpinLocation

  def initialize(name, lat, lon)
    @name = name
    @lat  = lat
    @lon  = lon
  end
  
  attr_reader :name
  attr_reader :lat
  attr_reader :lon

  class << self

    # 返回五个直辖市默认地址
    # 北京，上海，广州，天津，重庆
    def default_locations
      obj = {"results" =>[
        {"address_components"=>[{"long_name"=>"北京", "short_name"=>"北京", "types"=>["locality", "political"]}, {"long_name"=>"北京市", "short_name"=>"北京市", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"中国", "short_name"=>"CN", "types"=>["country", "political"]}], "geometry"=>{"location"=>{"lng"=>116.407413, "lat"=>39.904214}, "bounds"=>{"northeast"=>{"lng"=>117.5146251, "lat"=>41.0608158}, "southwest"=>{"lng"=>115.4234115, "lat"=>39.4427581}}, "location_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lng"=>116.7829835, "lat"=>40.2164962}, "southwest"=>{"lng"=>116.0119343, "lat"=>39.6612714}}}, "types"=>["locality", "political"], "formatted_address"=>"中国北京"},
        {"address_components"=>[{"long_name"=>"上海", "short_name"=>"上海", "types"=>["locality", "political"]}, {"long_name"=>"上海市", "short_name"=>"上海市", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"中国", "short_name"=>"CN", "types"=>["country", "political"]}], "geometry"=>{"location"=>{"lng"=>121.473704, "lat"=>31.230393}, "bounds"=>{"northeast"=>{"lng"=>122.2470663, "lat"=>31.868217}, "southwest"=>{"lng"=>120.8582175, "lat"=>30.68027}}, "location_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lng"=>122.1137989, "lat"=>31.6688967}, "southwest"=>{"lng"=>120.8397067, "lat"=>30.7798012}}}, "types"=>["locality", "political"], "formatted_address"=>"中国上海"},
        {"address_components"=>[{"long_name"=>"广州", "short_name"=>"广州", "types"=>["locality", "political"]}, {"long_name"=>"广东省", "short_name"=>"广东省", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"中国", "short_name"=>"CN", "types"=>["country", "political"]}], "geometry"=>{"location"=>{"lng"=>113.264435, "lat"=>23.129163}, "bounds"=>{"northeast"=>{"lng"=>114.0599571, "lat"=>23.9329877}, "southwest"=>{"lng"=>112.9585068, "lat"=>22.5598578}}, "location_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lng"=>113.7332153, "lat"=>23.555094}, "southwest"=>{"lng"=>112.7224731, "lat"=>22.6961015}}}, "types"=>["locality", "political"], "formatted_address"=>"中国广东省广州"},
        {"address_components"=>[{"long_name"=>"天津", "short_name"=>"天津", "types"=>["locality", "political"]}, {"long_name"=>"天津市", "short_name"=>"天津市", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"中国", "short_name"=>"CN", "types"=>["country", "political"]}], "geometry"=>{"location"=>{"lng"=>117.200983, "lat"=>39.084158}, "bounds"=>{"northeast"=>{"lng"=>118.0656116, "lat"=>40.2532141}, "southwest"=>{"lng"=>116.7080286, "lat"=>38.5555781}}, "location_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lng"=>117.8118896, "lat"=>39.4468325}, "southwest"=>{"lng"=>116.7791748, "lat"=>38.8032309}}}, "types"=>["locality", "political"], "formatted_address"=>"中国天津"},
        {"address_components"=>[{"long_name"=>"重庆", "short_name"=>"重庆", "types"=>["locality", "political"]}, {"long_name"=>"重庆市", "short_name"=>"重庆市", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"中国", "short_name"=>"CN", "types"=>["country", "political"]}], "geometry"=>{"location"=>{"lng"=>106.551557, "lat"=>29.56301}, "bounds"=>{"northeast"=>{"lng"=>110.1998582, "lat"=>32.2011871}, "southwest"=>{"lng"=>105.2897606, "lat"=>28.1602253}}, "location_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lng"=>106.8138242, "lat"=>29.7401968}, "southwest"=>{"lng"=>106.2832832, "lat"=>29.3696283}}}, "types"=>["locality", "political"], "formatted_address"=>"中国重庆"}
      ]}
      m = Hashie::Mash.new(obj)
      m.results
    end

    # 根据传入的位置名返回所有相关的地理位置实例数组
    def get_locations_by_name(name)
      json_str = open(URI.escape("http://maps.google.com/maps/api/geocode/json?address=#{name}&sensor=false&language=zh-CN")).read
      obj = ActiveSupport::JSON.decode(json_str)
      m = Hashie::Mash.new(obj)
      m.results
    end

    # coord. = coordinate
    # 根据传入的坐标返回所有相关的地理位置实例数组
    def get_locations_by_coord(lat, lng)
      json_str = open(URI.escape("http://maps.google.com/maps/api/geocode/json?latlng=#{lat},#{lng}&sensor=false&language=zh-CN")).read
      obj = ActiveSupport::JSON.decode(json_str)
      m = Hashie::Mash.new(obj)
      m.results
    end

  end

end
