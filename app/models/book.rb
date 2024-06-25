# frozen_string_literal: true

class Book < ApplicationRecord
  acts_as_paranoid

  attr_accessor :id_borrowing

  has_many :borrowings, dependent: :destroy
  has_many :users, through: :borrowings

  validates :title, :author, :description, :total_books, presence: true
  validates :total_books, :available_books, numericality: { greater_than_or_equal_to: 0 }
  validate :available_books_must_be_less_than_or_equal_to_total_books

  before_update :update_available_books

  scope :search_book, (lambda do |query = nil, admin = false|
    search_query = admin ? all.with_deleted : all
    if query.present?
      search_query = search_query.where('title ILIKE :query OR author ILIKE :query', query: "%#{query}%")
    end
    search_query
  end)

  # broadcasts_to ->(book) { :books }, inserts_by: :append
  after_create_commit -> { broadcast_prepend_to :books }
  after_update_commit lambda {
    broadcast_replace_to :book_all, partial: 'books/book_all'
    broadcast_replace_to :books
  }

  after_destroy_commit do
    broadcast_replace_later_to :books
    broadcast_replace_later_to :book_all, partial: 'books/book_all'
  end

  def restore(options = {})
    super(options)
    broadcast_replace_later_to :books
    broadcast_replace_later_to :book_all, partial: 'books/book_all'
  end

  private

  def available_books_must_be_less_than_or_equal_to_total_books
    errors.add(:total_books, :is_incorrect) if total_books && available_books > total_books
  end

  def update_available_books
    self.available_books += total_books - total_books_was if total_books_changed?
  end
end
