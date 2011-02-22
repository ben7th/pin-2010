module GitRepositoryMethods
  if RAILS_ENV != "test"
    GIT_REPO_PATH = YAML.load(CoreService.project("pin-workspace").settings)[:git_repo_path]
  else
    GIT_REPO_PATH = "/root/mindpin_base/git_repo_test"
  end
  
  attr_reader :user,:name,:repo

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(hash)
    @user = hash[:user] || User.find(hash[:user_id])
    if !@user.instance_of?(User)
      raise ":user 必须是 User 对象"
    end
    @name = hash[:repo_name]
    self.class.init_user_path(@user)

    @repo = Grit::Repo.new(self.path) if File.exist?(self.path)
  end

  # 该 git 版本库 的路径
  def path
    self.class.repository_path(@user.id,@name)
  end

  module ClassMethods
    # 初始化 用户用到的 所有地址
    def init_user_path(user)
      self.init_user_repository_path(user)
      self.init_user_recycle_path(user)
    end

    # 初始化 用户的 版本库 根地址
    def init_user_repository_path(user)
      path = self.user_repository_path(user.id)
      FileUtils.mkdir_p(path) if !File.exist?(path)
    end

    # 初始化 用户的 回收站 地址
    def init_user_recycle_path(user)
      path = self.user_recycle_path(user.id)
      FileUtils.mkdir_p(path) if !File.exist?(path)
    end

    # 用户的 版本库 根地址
    def user_repository_path(user_id)
      "#{GIT_REPO_PATH}/users/#{user_id}"
    end

    # 用户的 回收站 地址
    def user_recycle_path(user_id)
      "#{GIT_REPO_PATH}/deleted/users/#{user_id}"
    end

    # 用户 的 某个版本库 地址
    def repository_path(user_id,repo_name)
      "#{self.user_repository_path(user_id)}/#{repo_name}"
    end

    # 创建一个 git 版本库
    # gr = GitRepository.create(:user=>user,:repo_name=>"版本库名字")
    # 判断是否创建成功 gr.new_record? == false
    def create(hash)
      repo = self.new(hash)
      g = Grit::Repo.init(repo.path)
      # git config core.quotepath false
      # core.quotepath设为false的话，就不会对0x80以上的字符进行quote。中文显示正常
      g.config["core.quotepath"] = "false"
      return repo
    end
  end
end
