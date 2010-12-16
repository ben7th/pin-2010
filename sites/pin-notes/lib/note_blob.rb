class NoteBlob
  attr_reader :id,:basename,:data,:mime_type,:updated_at,:created_at
  def initialize(atts)
    atts.each do |k, v|
      instance_variable_set("@#{k}".to_sym, v)
    end
  end
end
