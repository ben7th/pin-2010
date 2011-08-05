class CollectionScope < UserAuthAbstract
  class UnSpecifiedError < StandardError;end
  class FormatError < StandardError;end
  
  ALL_PUBLIC = "all-public"
  ALL_FOLLOWINGS = "all-followings"
  
  belongs_to :collection
  belongs_to :scope, :polymorphic => true
  validates_presence_of :param

  def self.build_list_form_string(params_string)
    params_arr = params_string.split(",").uniq
    list = []
    arr = params_arr.select do |param|
      param == ALL_PUBLIC ||
        param == ALL_FOLLOWINGS
    end
    raise CollectionScope::FormatError,"发送范围 参数格式错误" if arr.count > 1
    ch_arr = params_arr.select do |param|
      !!(param =~ /ch-(\d+)/)
    end
    raise CollectionScope::FormatError,"发送范围 参数格式错误" if ch_arr.count > 0 && arr.count > 0

    params_arr.each do |param|
      case param
      when ALL_PUBLIC
        list << self.new(:param=>ALL_PUBLIC)
      when ALL_FOLLOWINGS
        list << self.new(:param=>ALL_FOLLOWINGS)
      when /ch-(\d+)/
        id = param.gsub("ch-","").to_i
        channel = Channel.find_by_id(id)
        next if channel.blank?
        list << self.new(:param=>param,:scope=>channel)
      when /u-(\d+)/
        id = param.gsub("u-","").to_i
        user = User.find_by_id(id)
        next if user.blank?
        list << self.new(:param=>param,:scope_id=>user.id,:scope_type=>user.class.to_s)
      else
        raise CollectionScope::FormatError,"发送范围 参数格式错误"
      end
    end
    raise CollectionScope::UnSpecifiedError,"必须指定发送范围" if list.blank?
    list
  end

  module CollectionMethods
    def self.included(base)
      base.has_many :collection_scopes
    end

    def public?
      scopes = self.collection_scopes.select{|ss|ss.param == CollectionScope::ALL_PUBLIC}
      scopes.count != 0
    end

    def sent_all_followings?
      scopes = self.collection_scopes.select{|ss|ss.param == CollectionScope::ALL_FOLLOWINGS}
      scopes.count != 0
    end

    def sent_channels
      channels = []
      self.collection_scopes.each do |ss|
        channels << ss.scope if ss.scope.is_a?(Channel)
      end
      channels
    end

    def sent_users
      users = []
      self.collection_scopes.each do |ss|
        users << ss.scope if ss.scope.is_a?(User)
      end
      users
    end
  end

  module ChannelMethods
    def self.included(base)
      base.has_many :collection_scopes, :as =>:scope
      base.has_many :out_collections_db,:through=>:collection_scopes,
        :source=>:collection,:order=>"collections.id desc"
    end
  end
end
