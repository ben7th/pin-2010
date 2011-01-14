atom_feed do |feed|
  feed.title("用户 #{@user.name} 的所有公开导图")
  feed.updated(@public_mindmaps.first.created_at)

  for mindmap in @public_mindmaps
    feed.entry(mindmap) do |entry|
      entry.title(mindmap.title)
      entry.content(mindmap.struct, :type => 'xml')

      entry.author do |author|
        author.name(@user.name)
        author.email(@user.email)
      end
    end
  end
end
