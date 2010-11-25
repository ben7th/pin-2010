require "pie-service-lib"
class AjaxTestMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/ajax_test/}
  end

  def self.deal(hash)
    return [200, {"Content-Type" => "text/xml"}, ["ok"]]
  end
end
