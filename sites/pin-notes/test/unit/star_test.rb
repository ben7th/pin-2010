require 'test_helper'

class StarTest < ActiveSupport::TestCase

  test "star 一个 note " do
    note_test do |note|
      lucy = users(:lucy)
      assert_equal false,lucy.star_note?(note)
      lucy.star_note(note)
      lucy.reload
      assert_equal true,lucy.star_note?(note)
      assert_equal lucy.starred_notes.count,1
      assert lucy.starred_notes,[note]

      lucy.unstar_note(note)
      lucy.reload
      assert_equal false,lucy.star_note?(note)
      assert_equal lucy.starred_notes.count,0

    end
  end
end
