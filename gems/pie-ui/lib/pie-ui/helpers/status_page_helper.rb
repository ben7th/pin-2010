module StatusPageHelper
  def show_status_code(code)
    {
      403=>'当前用户对指定资源没有操作权限',
      404=>'指定的资源没有找到',
      422=>'对指定资源的请求无效',
      500=>'网站程序错误'
    }[code.to_i] || ''
  end
end
