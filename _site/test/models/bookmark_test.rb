require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should not allow duplicate urls for same user" do
    # 最初のユーザーを作成
    user1 = User.create!(email: "test1@example.com", password: "password", password_confirmation: "password")
    
    # 最初のユーザーのブックマークを作成
    bookmark1 = user1.bookmarks.create!(url: "https://example.com", title: "Example")
    
    # 同じユーザーが同じURLで別のブックマークを作成しようとすると失敗する
    duplicate_bookmark = user1.bookmarks.build(url: "https://example.com", title: "Example Duplicate")
    assert_not duplicate_bookmark.valid?
    assert_includes duplicate_bookmark.errors[:url], "は既に登録されています"
    
    # 別のユーザーは同じURLでブックマークを作成できる
    user2 = User.create!(email: "test2@example.com", password: "password", password_confirmation: "password")
    bookmark2 = user2.bookmarks.build(url: "https://example.com", title: "Example")
    assert bookmark2.valid?
  end
end
