
def show_feed(id)
  p "show_feed"
  open("http://dev.www.mindpin.com/feeds/#{id}")
end

def write_file
  p "write_file"
  File.open("/tmp/write_some_data_for_wake_up.log","w") do |f|
    f << %`
        IDS = Feed.find(:all,:limit=>1000,:select=>"id").map{|f|f.id}
        COUNT = IDS.count
        def show_feed
        p "show_feed"
        id = IDS[rand(count-1)]
        open("http://dev.www.mindpin.com/feeds/")
        end

        def write_file
        p "write_file"
        end


        while true do
        write_file
        show_feed
        sleep 30
        end
    `
  end
end

ids = Feed.find(:all,:limit=>1000,:select=>"id").map{|f|f.id}
count = ids.count

while true do
  begin
    id = ids[rand(count-1)]
    write_file
    show_feed id
  rescue Exception=>ex
    p '...'
  ensure
    sleep 30
  end
end
