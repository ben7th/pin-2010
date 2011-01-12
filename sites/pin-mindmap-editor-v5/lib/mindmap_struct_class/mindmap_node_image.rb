class MindmapNodeImage
  def initialize(nokogiri_node)
    @nokogiri_node = nokogiri_node
  end

  def remove
    @nokogiri_node.remove_attribute("img")
    @nokogiri_node.remove_attribute("imgw")
    @nokogiri_node.remove_attribute("imgh")
  end
  
  def url
    @nokogiri_node['img']
  end

  def url=(url)
    @nokogiri_node['img'] = url
  end

  def width
    @nokogiri_node['imgw']
  end

  def width=(width)
    @nokogiri_node['imgw'] = width
  end

  def height
    @nokogiri_node['imgh']
  end

  def height=(height)
    @nokogiri_node['imgh'] = height
  end
end
