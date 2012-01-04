require "weibo"
Weibo::Config.api_key = Tsina::API_KEY
Weibo::Config.api_secret = Tsina::API_SECRET
class ReadTsinaMessage
  MAX_TSINA_MESSAGE_ID_FILE_PATH = File.join(Rails.root,"config/max_tsina_message_id")
  def self.run
    self.init_max_tsina_message_id_file
    access_token = "a3ac1464078fb0ad509c7a6796159766"
    access_secret = "be28c4f393cebb5c5650aa8f5ab075a9"
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_access(access_token, access_secret)
    wb = Weibo::Base.new(oauth)
    loop do
      id = self.current_max_tsina_message_id
      result = wb.mentions(:since_id=>id)
      process_result(result,wb)
      sleep 3*60
    end
  end

  def self.process_result(result,wb)
    p "得到 #{result.count} new message"
    if result.count > 0
      result.each do |item|
        connect_id = item.user.id
        cu = ConnectUser.find_by_connect_id_and_connect_type(connect_id,ConnectUser::TSINA_CONNECT_TYPE)
        if !!cu
          cu.user.send_message_to_tsina_weibo(item.text)
          wb.update("@#{item.user.name} 收到了 #{Time.now.to_f}")
        end
      end
      self.current_max_tsina_message_id=result.first.id
    end
  end

  def self.init_max_tsina_message_id_file
    if !File.exists?(MAX_TSINA_MESSAGE_ID_FILE_PATH)
      File.open(MAX_TSINA_MESSAGE_ID_FILE_PATH,"w"){|f|f << "0"}
    end
  end

  # 当前处理到的 最大的 message_id
  def self.current_max_tsina_message_id
    IO.read(MAX_TSINA_MESSAGE_ID_FILE_PATH).to_i
  end

  # 设置当前处理到的 最大的 message_id
  def self.current_max_tsina_message_id=(id)
    File.open(MAX_TSINA_MESSAGE_ID_FILE_PATH,"w"){|f|f << id.to_s}
  end
end
