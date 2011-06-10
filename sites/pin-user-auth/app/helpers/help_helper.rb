module HelpHelper
  def helpimg(name,height)
    "<img src='/images/help/startup-#{name}.png' width='500' height='#{height}' />"
  end

  def testdiff
    MindpinDiff.test1
  end
end
