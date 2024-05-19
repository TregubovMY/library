# frozen_string_literal: true

class CreateBorrowings < ActiveRecord::Migration[7.1]
  def change
    create_table :borrowings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :returned_at

      t.timestamps
    end

    add_index :borrowings, %i[user_id book_id],
              unique: true, where: 'returned_at IS NULL', name: 'index_borrowings_on_user_id_and_book_id'
  end
end
