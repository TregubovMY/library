# frozen_string_literal: true

class Book < ApplicationRecord
  acts_as_paranoid

  has_many :borrowings, dependent: :destroy
  has_many :users, through: :borrowings

  validates :title, :author, :description, :total_books, presence: true
  validates :total_books, :available_books, numericality: { greater_than_or_equal_to: 0 }
  validate :available_books_must_be_less_than_or_equal_to_total_books

  before_update :update_available_books

  scope :search_book, (lambda do |query = nil, admin = false|
    search_query = admin ? all.with_deleted : all
    search_query = search_query.where('title ILIKE :query OR author ILIKE :query', query: "%#{query}%") if query.present?
    search_query
  end)

  after_create_commit { broadcast_prepend_to 'books', target: :books_list }
  # after_update_commit { broadcast_replace_to "book_#{id}" }

  private

  def available_books_must_be_less_than_or_equal_to_total_books
    errors.add(:total_books, :is_incorrect) if total_books && available_books > total_books
  end

  def update_available_books
    self.available_books += total_books - total_books_was if total_books_changed?
  end
end
