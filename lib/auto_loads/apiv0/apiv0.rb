class Apiv0
  class << self

    def send_feed_by_user(user, options={})
      title          = options[:title]
      detail         = options[:detail]
      photo_names    = options[:photo_names]
      collection_ids = options[:collection_ids]
      send_tsina     = options[:send_tsina]
      from           = options[:from]

      raise Apiv0::ParamsNotValidException.new('不要发送一个空主题') if title.blank? && detail.blank? && photo_names.blank?
      raise Apiv0::ParamsNotValidException.new('必须指定收集册') if collection_ids.blank?

      feed = user.send_feed(
        :title          => title,
        :detail         => detail,
        :photo_names    => photo_names,
        :collection_ids => collection_ids,
        :from           => from,
        :send_tsina     => send_tsina
      )

      if feed.id.blank?
        feed.valid?
        raise Apiv0::ParamsNotValidException.new(feed.errors.first[1])
      end

      return feed
    end

  end

  class ParamsNotValidException < Exception; end
end
