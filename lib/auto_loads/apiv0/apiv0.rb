class Apiv0
  class << self

    def send_feed_by_user(user, options={})
      title          = options[:title]
      detail         = options[:detail]
      photo_ids      = options[:photo_ids]
      collection_ids = options[:collection_ids]
      send_tsina     = options[:send_tsina]
      from           = options[:from]
      location       = options[:location]

      raise Apiv0::ParamsNotValidException.new('不要发送一个空主题') if title.blank? && detail.blank? && photo_ids.blank?
      raise Apiv0::ParamsNotValidException.new('必须指定收集册') if collection_ids.blank?

      feed = user.send_feed(
        :title          => title,
        :detail         => detail,
        :photo_ids      => photo_ids,
        :collection_ids => collection_ids,
        :from           => from,
        :send_tsina     => send_tsina,
        :location       => location
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
