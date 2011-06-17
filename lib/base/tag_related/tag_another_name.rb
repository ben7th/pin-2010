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
      another_tags.each do |tag|
        tag.feeds.each do |feed|
          ft = feed.feed_tags.find_by_tag_id(tag.id)
          ft.destroy
          FeedTag.create!(:tag=>mtag,:feed=>feed)
        end
        TagAnotherName.create(:name=>tag.name,:tag=>mtag)
      end

    end
    
  end
end
