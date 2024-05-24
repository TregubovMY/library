class AddIndexToBooks < ActiveRecord::Migration[7.1]
  def change
    add_index :books, :title
    add_index :books, :author
  end
end
