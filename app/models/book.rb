# frozen_string_literal: true

class Book < ApplicationRecord
  validates :title, :author, :description, presence: true
end
