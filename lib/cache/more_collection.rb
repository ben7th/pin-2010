class MoreCollection < Array
  attr_reader :last_value,:is_end
  def initialize(result,last_value,is_end)
    @last_value = last_value
    @is_end = is_end
    replace(result)
  end
end
