class HttpUtil
  def self.get_body_by_url(url_str,timeout=10)
    uri = URI.parse(url_str)
    self.get_body(uri,timeout)
  end

  def self.get_tempfile_by_url(url_str,timeout=10)
    uri = URI.parse(url_str)
    extname = File.extname(uri.path)
    basename = File.basename(uri.path, extname)
    file = Tempfile.new([basename,extname])
    file.binmode
    file.write(self.get_body(uri,timeout))
    file.rewind
    file
  end

  private
  def self.get_body(uri,timeout)
    resp = self.get_response(uri,timeout)
    if resp.status < 400
      return resp.body
    else
      raise "链接错误"
    end
  end

  def self.get_response(uri,timeout)
    sess = Patron::Session.new
    sess.timeout = timeout
    sess.base_url = "#{uri.scheme}://#{uri.host}"
    sess.headers['User-Agent'] = 'Mozilla/5.0'

    path = uri.query ? "#{uri.path}?#{uri.query}" : uri.path
    sess.get(path)
  end
end
