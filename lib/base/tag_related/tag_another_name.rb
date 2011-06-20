class TagAnotherName < UserAuthAbstract
  belongs_to :tag

  validates_presence_of :tag
  validates_presence_of :name


  def self.merge_tag(full_name,another_names)
    namespace = Tag.get_namespace_from_tag_full_name(full_name)
    mname = Tag.get_name_from_tag_full_name(full_name)
    mtag = Tag.find_by_name_and_namespace(mname,namespace)

    another_tags = another_names.map do |name|
      Tag.find_by_name_and_namespace(name,namespace)
    end

    ActiveRecord::Base.transaction do
      tags_count = another_tags.length
      another_tags.each_with_index do |tag,tindex|
        feeds = tag.feeds
        count = feeds.length
        feeds.each_with_index do |feed,index|
          p "共#{tags_count}个关键词，正在处理第#{tindex+1}个关键词 #{tag.name} #{index+1}/#{count}"

          ft = feed.feed_tags.find_by_tag_id(tag.id)
          ft.destroy
          FeedTag.create!(:tag=>mtag,:feed=>feed)
        end
        TagAnotherName.create(:name=>tag.name,:tag=>mtag)
      end

    end
    
  end

  module TagMethods
    def self.included(base)
      base.has_many :tag_another_names
    end

    def another_name_tags
      self.tag_another_names.map do|tan|
        Tag.find_by_name_and_namespace(tan.name,self.namespace)
      end.compact
    end
  end
end
