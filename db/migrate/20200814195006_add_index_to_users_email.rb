class AddIndexToUsersEmail < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :emial, unique: true
  end
end
