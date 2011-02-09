class Organization < OrganizationBase
  set_readonly false

  index :email
  has_many :members,:foreign_key => "organization_id",:dependent=>:destroy

  validates_presence_of :name
  validates_uniqueness_of :email,:if=>Proc.new{|u|!u.email.blank?}
  validates_format_of :email,
    :with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/,
    :if=>Proc.new{|u|!u.email.blank?}

  def validate
    if !email.blank? && EmailActor.new(email).not_allow_used? && EmailActor.new(email).actor != self
      errors.add(:email,"团队邮箱地址已经被使用")
    end
  end

  #SELECT `organizations`.* FROM `organizations` INNER JOIN `members` ON `organizations`.id = `members`.organization_id WHERE ((`members`.email = 271)

  # 判断 名字是否重复
  def name_repeated?
    Organization.find_all_by_name(name).count > 1
  end
  
  def can_leave?(user)
    !(owners.count == 1 && is_owner?(user))
  end

  def leave(user)
    if can_leave?(user)
      member_1 = Member.find_by_organization_id_and_email(id,user.email)
      mindpin_email = EmailActor.get_mindpin_email(user)
      member_2 = Member.find_by_organization_id_and_email(id,mindpin_email)
      member_1.destroy if member_1
      member_2.destroy if member_2
      return true
    end
    return false
  end

  def activities
    Activity.find(:all,:conditions=>{:location=>"Organization##{self.id}"},:order=>"updated_at desc")
  end

  # 属于 这个团队的协同编辑的导图
  def cooperate_edit_mindmaps
    emails = [self.logic_email,self.mindpin_email].uniq
    coos = emails.map{|email|Cooperation.find(:all,:conditions=>"cooperations.email = '#{email}' and cooperations.kind = '#{Cooperation::EDITOR}'")}.flatten.uniq
    mindmaps = coos.map{|coo|coo.mindmap}.uniq.compact
    mindmaps
  end

  # 属于 这个团队的协同查看的导图
  def cooperate_view_mindmaps
    emails = [self.logic_email,self.mindpin_email].uniq
    coos = emails.map{|email|Cooperation.find(:all,:conditions=>"cooperations.email = '#{email}' and cooperations.kind = '#{Cooperation::VIEWER}'")}.flatten.uniq
    mindmaps = coos.map{|coo|coo.mindmap}.uniq.compact
    mindmaps
  end

  module UserMethods
    def validate
      if !email.blank? && EmailActor.new(email).not_allow_used? && EmailActor.new(email).actor != self
        errors.add(email,"邮箱地址已经被使用过了")
      end
    end
  end

end
