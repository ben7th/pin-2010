class EmailActor
  def initialize(email)
    @email = email
  end

  def email
    @email
  end
  
  def actor
    @actor ||=
    (User.find_by_email(@email) || EmailActor.get_organization_by_email(@email) || @email)
  end
  
  def name
    _actor = self.actor
    case _actor
    when User
      _actor.name
    when Organization
      _actor.name
    when String
      '匿名'
    end
  end

  # 当 email 为 organization97@mindpin.com 时
  # 对应 id 是 97 的 organization
  def self.get_organization_by_email(email)
    ma = /organization(\d+)@mindpin.com/.match(email)
    Organization.find_by_email(email) || Organization.find_by_id(ma[1])
  rescue
    nil
  end
  
  def self.get_logic_email(obj)
    return obj.email.nil? ? "#{obj.class.to_s.downcase}#{obj.id}@mindpin.com" : obj.email
  end

  def self.unique(ea_array)
    begin
      ret,done = [],[]
      ea_array.each do |ea|
        actor = ea.actor
        if !done.include?(actor)
          done << actor
          ret << ea
        end
      end
    rescue Exception => ex
      ret = ea_array
    end
    
    return ret
  end
end
