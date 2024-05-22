# frozen_string_literal: true

class AddBookCountsToBooks < ActiveRecord::Migration[7.1]
  def change
    change_table :books, bulk: true do |t|
      t.integer :total_books, default: 0
      t.integer :available_books, default: 0
    end
  end
end
