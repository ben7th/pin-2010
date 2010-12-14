class Share < ActiveResource::Base
  self.site = SHARE_API_SITE
  self.element_name = "share"

  # user = User.find(2)
  # Share.create({"kind"=>"TALK", "content"=>"什么情况"},:remote_user=>user)

  def self.create(attributes = {}, options={})
    self.new(attributes).tap { |share| share.save(options) }
  end

  def save(options={})
    new? ? create(options) : update(options)
  end

  def create(options)
    headers={}
    headers['X-USERID'] = options[:remote_user].id.to_s
    connection.post(collection_path, encode, headers).tap do |response|
      self.id = id_from_response(response)
      load_attributes_from_response(response)
    end
  end
end