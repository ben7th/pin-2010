class MindmapNodeImage
  def initialize(nokogiri_node)
    @nokogiri_node = nokogiri_node
  end

  def img_attach_id=(img_attach_id)
    @nokogiri_node['img_attach_id'] = img_attach_id
  end

  def img_attach_id
    @nokogiri_node['img_attach_id']
  end

  def remove
    @nokogiri_node.remove_attribute("img_attach_id")
  end

  def url
    return if img_attach_id.blank?
    return defalut_image_url if image_attachment.blank?
    image_attachment.image.url(:thumb)
  end

  def path
    return if img_attach_id.blank?
    return defalut_image_path if image_attachment.blank?
    image_attachment.image.path(:thumb)
  end

  def width
    size[:width]
  end

  def height
    size[:height]
  end

  def to_hash
    return if img_attach_id.blank?

    {
      :attach_id=>img_attach_id,
      :url=>url,
      :height=>height,
      :width=>width
    }
  end

  private
  def image_attachment
    @image_attachment||=begin
      iaid = img_attach_id
      return if iaid.blank?
      ImageAttachment.find_by_id(iaid)
    end
  end

  def size
    @size||=begin
      return {} if img_attach_id.blank?
      return {:height=>23,:width=>75} if image_attachment.blank?
      image_attachment.image_size(:thumb)
    end
  end

  def defalut_image_path
    "#{RAILS_ROOT}/public/images/img_attach_deleted.png"
  end

  def defalut_image_url
    pin_url_for("pin-daotu","images/img_attach_deleted.png")
  end
end
