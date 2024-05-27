# frozen_string_literal: true

class Book < ApplicationRecord
  acts_as_paranoid

  has_many :borrowings, dependent: :destroy
  has_many :users, through: :borrowings

  validates :title, :author, :description, :total_books, presence: true
  validates :total_books, :available_books, numericality: { greater_than_or_equal_to: 0 }
  validate :available_books_must_be_less_than_or_equal_to_total_books

  before_update :update_available_books

  scope :search_book, (lambda do |title = nil, author = nil, admin = false|
    query = admin ? all.with_deleted : all
    query = query.where('title LIKE ?', "%#{title}%") if title.present?
    query = query.where('author LIKE ?', "%#{author}%") if author.present?
    query
  end)

  private

  def available_books_must_be_less_than_or_equal_to_total_books
    errors.add(:total_books, :is_incorrect) if total_books && available_books > total_books
  end

  def update_available_books
    self.available_books += total_books - total_books_was if total_books_changed?
  end
end
