require 'test_helper'

class NoteTest < ActiveSupport::TestCase

  test "创建 删除 note" do
    repo_test do |lifei|
      assert_difference("Note.count",1) do
        note = lifei.notes.create
        assert File.exist?(note.repository_path)
        assert_equal note.repository_path,"#{Note::REPOSITORIES_PATH}/#{note.id}"
        assert_equal note.grit_repo.working_dir,note.repository_path
      end

      note = Note.last
      assert_difference("Note.count",-1) do
        note.destroy
        assert !File.exist?(note.repository_path)
      end
    end
  end

  test "创建 私有 note" do
    repo_test do |lifei|
      assert_difference("Note.count",1) do
        note = lifei.notes.create(:private=>true)
        assert File.exist?(note.repository_path)
        assert_equal note.repository_path,"#{Note::REPOSITORIES_PATH}/#{note.private_id}"
        assert_equal note.grit_repo.working_dir,note.repository_path
      end

      note = Note.last
      assert_difference("Note.count",-1) do
        note.destroy
        assert !File.exist?(note.repository_path)
      end
    end
  end

  test "编辑内容" do
    repo_test do |lifei|
      note = lifei.notes.create
      assert_equal note.text_hash.keys.count,0
      assert_equal note.blobs.count,0
      # 编辑内容
      text_1 = "我是第一个片段"
      text_hash_1 = {"#{Note::NOTE_FILE_PREFIX}1"=>text_1}
      note.save_text_hash!(text_hash_1)
      assert_equal note.text_hash.keys.count,1
      assert_equal note.blobs.count,1
      assert_equal note.text_hash,text_hash_1
      sleep 1
      # 再次编辑内容
      text_2 = "我是第二个片段"
      text_3 = "我是第三个片段"
      text_hash_2 = {"#{Note::NOTE_FILE_PREFIX}1"=>text_1,
        "#{Note::NOTE_FILE_PREFIX}2"=>text_2,
        "#{Note::NOTE_FILE_PREFIX}3"=>text_3
      }
      note.save_text_hash!(text_hash_2)
      assert_equal note.text_hash.keys.count,3
      assert_equal note.blobs.count,3
      assert_equal note.text_hash,text_hash_2

      # 编辑内容
      sleep 1
      edit_text_1 = "修改第一个片段"
      text_hash_3 = {"#{Note::NOTE_FILE_PREFIX}1"=>edit_text_1,
        "#{Note::NOTE_FILE_PREFIX}3"=>text_3
      }
      note.save_text_hash!(text_hash_3)
      assert_equal note.text_hash.keys.count,2
      assert_equal note.blobs.count,2
      assert_equal note.text_hash,text_hash_3

      # 版本快照
      text_hash_array = note.commit_ids.map do |id|
        note.text_hash(id)
      end
      assert_equal text_hash_array.count,3
      # 最新的版本
      assert_equal text_hash_array[0].count,2
      assert_equal text_hash_array[0],text_hash_3
      # 倒数第二个版本
      assert_equal text_hash_array[1].count,3
      assert_equal text_hash_array[1],text_hash_2
      # 第一个版本
      assert_equal text_hash_array[2].count,1
      assert_equal text_hash_array[2],text_hash_1
      # 重命名
      sleep 1
      rename_hash = {"#{Note::NOTE_FILE_PREFIX}1"=>"#{Note::NOTE_FILE_PREFIX}11",
        "#{Note::NOTE_FILE_PREFIX}3"=>"#{Note::NOTE_FILE_PREFIX}33"
      }
      note.save_text_hash!({"#{Note::NOTE_FILE_PREFIX}11"=>"xinneirong"},rename_hash)
      assert_equal note.text_hash.keys.count,2
      assert note.text_hash.keys.include?("#{Note::NOTE_FILE_PREFIX}11")
      assert note.text_hash.keys.include?("#{Note::NOTE_FILE_PREFIX}33")
    end
  end

  test "fork" do
    repo_test do |lifei|
      note = lifei.notes.create
      assert_equal note.text_hash.keys.count,0
      assert_equal note.blobs.count,0
      # 编辑内容
      text_1 = "我是第一个片段"
      text_hash_1 = {"#{Note::NOTE_FILE_PREFIX}1"=>text_1}
      note.save_text_hash!(text_hash_1)
      assert_equal note.text_hash.keys.count,1
      assert_equal note.blobs.count,1
      assert_equal note.text_hash,text_hash_1

      # fork
      lucy = users(:lucy)
      assert_equal note.fork_from,nil
      new_note = Note.fork(note,lucy)
      assert_equal new_note.user.id,lucy.id
      assert_equal new_note.id,note.id + 1
      assert_equal new_note.private,false
      assert_equal new_note.text_hash.keys.count,1
      assert_equal new_note.blobs.count,1
      assert_equal new_note.text_hash,text_hash_1
      assert new_note.fork_from[:note_id],note.id
      assert new_note.fork_from[:email],note.user.email
    end
  end


end
