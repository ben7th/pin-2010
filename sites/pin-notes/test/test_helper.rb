ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # 创建版本库测试环境
  def repo_test
    lifei = users(:repo_lifei)
    clear_user_repositories(lifei)
    yield lifei
    #    clear_user_repositories(lifei)
  end

  # 清空 测试创建的版本库文件
  def clear_user_repositories(user)
    FileUtils.rm_rf(NoteRepository.repositories_path)
    FileUtils.rm_rf(NoteRepository.user_recycle_path(user.id))
  end

  # 创建 note 测试环境
  def note_test
     repo_test do |lifei|
      assert_difference("Note.count",1) do
        note = lifei.notes.create
        assert File.exist?(note.repo.path)
      end
      note = Note.last
      yield note
    end
  end
end
