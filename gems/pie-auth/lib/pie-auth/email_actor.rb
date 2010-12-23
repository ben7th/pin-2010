class EmailActor
  def initialize(email)
    @email = email
  end

  def email
    @email
  end

  def actor
    @actor ||= self.class.get_actor_by_email(@email)
  end

  def name
    _actor = self.actor
    case _actor
    when UserBase
      _actor.name
    when OrganizationBase
      _actor.name
    when String
      '匿名'
    end
  end

  def email_name
    "#{self.email}#{self.name=='匿名' ? '':"(#{self.name})"}"
  end

  # other_email 代表的 email_actor 是否从属 该 email_actor
  def include?(other_email)
    other_ea = EmailActor.new(other_email)
    # 两个代表 一个 实体
    return true if other_ea.actor == self.actor
    # 该email_actor 代表团队，并且 other_email 属于这个团队
    if self.actor.is_a?(OrganizationBase)
      return self.actor.all_member_emails.include?(other_ea.email)
    end
    # 其它情况都不属于从属关系
    return false
  end

  # 该 email_actor 是否属于一个邮件列表
  def belonging?(email_list)
    belonging = false
    email_list.each do |email|
      if EmailActor.new(email).include?(self.email)
        belonging = true
        break
      end
    end
    return belonging
  end

  # 当 email 为 organization97@mindpin.com 时
  # 对应 id 是 97 的 organization
  def self.get_organization_by_email(email)
    ma = /organization(\d+)@mindpin.com/.match(email)
    Organization.find_by_email(email) || Organization.find_by_id(ma[1])
  rescue
    nil
  end

  # 根据 email 找到 它对应的实体
  # 用户，团队，普通邮箱
  def self.get_actor_by_email(email)
    (User.find_by_email(email) || EmailActor.get_organization_by_email(email) || email)
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
