# frozen_string_literal: true

class AddToBorrowingsDeletedAt < ActiveRecord::Migration[7.1]
  def change
    add_column :borrowings, :deleted_at, :datetime
    add_index :borrowings, :deleted_at
  end
end
