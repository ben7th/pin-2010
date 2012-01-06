module StatusPageHelper
  
  def show_status_code(code)
    {
      401 => '用户未登录',
      403 => '当前用户对指定资源没有操作权限',
      404 => '没有找到指定资源',
      422 => '对指定资源的请求无效',
      500 => '服务出错了'
    }[code.to_i] || '服务出错了'
  end
  
end