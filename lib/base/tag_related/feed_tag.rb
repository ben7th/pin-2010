class FeedTag < UserAuthAbstract
  belongs_to :feed
  belongs_to :tag,:class_name=>"Tag",:foreign_key=>:tag_name,:primary_key=>:name
  validates_presence_of :feed
  validates_presence_of :tag

  module FeedMethods
    def self.included(base)
      base.has_many :feed_tags
    end

    def tag_names
      self.feed_tags.map{|ft|ft.tag_name}
    end

    def add_tags(tag_names_string)
      names = tag_names_string.split(/[，, ]+/)
      names.each do |name|
        tag = Tag.find_or_create_by_name(name)
        next if tag.blank?
        FeedTag.find_or_create_by_feed_id_and_tag_name(self.id,tag.name)
      end
    end

    def remove_tag(tag_name)
      ft = self.feed_tags.find_by_tag_name(tag_name)
      ft.destroy unless ft.blank?
    end
  end

  module TagMethods
    def self.included(base)
      base.has_many :feed_tags,:foreign_key=>:tag_name,:primary_key=>:name
      base.has_many :feeds,:through=>:feed_tags
    end

  end
end
