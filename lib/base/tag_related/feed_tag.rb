class FeedTag < UserAuthAbstract
  version 20110513
  belongs_to :feed
  belongs_to :tag
  validates_presence_of :feed
  validates_presence_of :tag

  module FeedChangeMethods
    def self.included(base)
      base.after_create :add_default_tag_on_feed_update
    end

    def add_default_tag_on_feed_update
      self.feed.add_default_tag_when_no_tag
    end
  end

  module FeedMethods
    def self.included(base)
      base.has_many :feed_tags
      base.after_update :add_default_tag_when_no_tag
    end

    def add_default_tag_when_no_tag
      if self.tag_names.blank?
        self.add_tags(Tag::DEFAULT)
      end
      return true
    end

    def tag_names
      FeedTag.find_all_by_feed_id(self.id).map{|ft|ft.tag.name}
    end

    # 增加tag
    def add_tags(tag_names_string)
      names = tag_names_string.split(/[，, ]+/)
      old_tag_names = self.tag_names
      return if (names - old_tag_names) == []
      
      names.each do |name|
        tag = Tag.find_or_create_by_name(name)
        next if tag.blank?
        FeedTag.find_or_create_by_feed_id_and_tag_id(self.id,tag.id)
      end
    end

    # 移除指定的一个tag
    def remove_tag(tag_name)
      old_tag_names = self.tag_names
      return unless old_tag_names.include?(tag_name)
      
      tag = Tag.find_by_name(tag_name)
      ft = self.feed_tags.find_by_tag_id(tag.id)
      ft.destroy
    end

    # 根据传入的字符串修改tag
    def change_tags(tag_names_string,editor)
      new_names = tag_names_string.split(/[，, ]+/)
      old_names = self.tag_names

      arr_add = new_names - old_names
      arr_remove = old_names - new_names

      self.add_tags(arr_add*',')
      
      arr_remove.each do |name|
        self.remove_tag(name)
      end
      
      if !arr_add.blank? || !arr_remove.blank?
        self.record_editer(editor)
      end

      return self.tag_names
    end

  end

  module TagMethods
    def self.included(base)
      base.has_many :feed_tags
      base.has_many :feeds,:through=>:feed_tags,:order=>"feeds.updated_at desc"
    end

    def feeds_limited(count)
      self.feeds.find(:all,:limit=>count.to_i)
    end
  end
end
