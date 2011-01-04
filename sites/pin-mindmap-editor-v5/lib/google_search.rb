class GoogleSearch
  def initialize(query)
    @query = query
  end

  def relative_content
    @relative_content ||= {:pages=>pages,:images=>images}
  end

  def pages
    @pages ||= (pages = []
    Google::Search::Web.new(:query=>@query,:size=>:small).get_response.each{|item|pages << item}
    pages)
  end

  def images
    @images ||=(
    images = []
    Google::Search::Image.new(:query=>@query,:size=>:small).get_response.each{|item|images << item}
    images)
  end

end
