# frozen_string_literal: true

class FixColumnNameInUser < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :mobile, :phone
  end
end
