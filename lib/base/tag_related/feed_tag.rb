class FeedTag < UserAuthAbstract
  belongs_to :feed
  belongs_to :tag
  validates_presence_of :feed
  validates_presence_of :tag
  validates_uniqueness_of :feed_id, :scope => :tag_id

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
      base.has_many :feed_tags,:order=>"feed_tags.id asc"
      base.has_many :tags,:through=>:feed_tags,:source=>:tag,:order=>"feed_tags.id asc"
      base.after_update :add_default_tag_when_no_tag
    end

    def add_default_tag_when_no_tag
      if self.tag_names.blank?
        self.add_tag_without_record_editer(Tag::DEFAULT)
      end
      return true
    end

    def tag_names
      FeedTag.find_all_by_feed_id(self.id).map{|ft|ft.tag.full_name}
    end

    def add_tag_without_record_editer(tag_name,namespace = nil)
      tag = Tag.find_or_create_by_name_and_namespace(tag_name,namespace)
      FeedTag.find_or_create_by_feed_id_and_tag_id(self.id,tag.id)
    end

    def remove_tag_without_record_editer(tag_name,namespace = nil)
      tag = Tag.get_tag(tag_name,namespace)
      ft = self.feed_tags.find_by_tag_id(tag.id)
      ft.destroy unless ft.blank?
    end

    def add_tags_without_record_editer(tag_names_string,editor)
      new_names = Tag.get_tag_names_by_string(tag_names_string,editor)
      old_names = self.tag_names

      arr_add = new_names - old_names
      arr_add.each do |tag_full_name|
        namespace = Tag.get_namespace_from_tag_full_name(tag_full_name)
        name = Tag.get_name_from_tag_full_name(tag_full_name)
        self.add_tag_without_record_editer(name,namespace)
      end
    end

    # 根据传入的字符串修改tag
    def change_tags(tag_names_string,editor)
      return if self.locked? && !editor.is_admin_user?

      new_names = Tag.get_tag_names_by_string(tag_names_string,editor)
      old_names = self.tag_names

      arr_add = new_names - old_names
      arr_remove = old_names - new_names

      arr_add.each do |tag_full_name|
        namespace = Tag.get_namespace_from_tag_full_name(tag_full_name)
        name = Tag.get_name_from_tag_full_name(tag_full_name)
        self.add_tag_without_record_editer(name,namespace)
      end

      arr_remove.each do |tag_full_name|
        namespace = Tag.get_namespace_from_tag_full_name(tag_full_name)
        name = Tag.get_name_from_tag_full_name(tag_full_name)
        self.remove_tag_without_record_editer(name,namespace)
      end

      if !arr_add.blank? || !arr_remove.blank?
        self.record_editer(editor)
      end

      return self.tag_names
    end

  end

  module TagMethods
    def self.included(base)
      base.has_many :feed_tags,:order=>"feed_tags.id desc"
      base.has_many :feeds,:through=>:feed_tags,:order=>"feed_tags.id desc"
    end

    def feeds_limited(count)
      # 只显示非隐藏的
      self.feeds.normal.find(:all,:limit=>count.to_i)
    end
  end

  include TagRelatedFeedTagsMapProxy::FeedTagMethods
end
