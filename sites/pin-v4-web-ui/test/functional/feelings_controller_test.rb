require 'test_helper'

class FeelingsControllerTest < ActionController::TestCase

  test "对某entry进行好差评价" do
    clear_model(Feeling)
    entry = entries(:entry_1)
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    assert_difference("Feeling.count", 1) do
      put :update,:entry_id=>entry.id,:evaluation=>Feeling::GOOD
    end
    feeling = Feeling.last
    assert_equal feeling.feelable,entry
    assert_equal feeling.evaluation,Feeling::GOOD
  end
  
end
