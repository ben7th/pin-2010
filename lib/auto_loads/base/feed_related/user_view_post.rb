class UserViewPost < UserAuthAbstract
    BUCUO = "BUCUO"
    HENHAO = "HENHAO"
    JINGYA = "JINGYA"
    BUHAO = "BUHAO"
    XIHUAN = "XIHUAN"

  ATTITUDES = [
    BUCUO,
    HENHAO,
    JINGYA,
    BUHAO,
    XIHUAN
  ]

  belongs_to :post
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :post
  validates_uniqueness_of :user_id, :scope => :post_id
  validates_inclusion_of :attitude, :in=>ATTITUDES


end
