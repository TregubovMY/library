# frozen_string_literal: true

class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validate :return_date_after_borrow_date

  scope :search_book_by_user, lambda { |user, title = nil, author = nil|
    query = borrowing_by_user(user)
    query = query.where('title LIKE ?', "%#{title}%") if title.present?
    query = query.where('author LIKE ?', "%#{author}%") if author.present?
    query
  }

  def self.borrowing_by_user(user)
    select('books.*, book_id').where(user_id: user.id, returned_at: nil).joins(:book)
  end

  def self.borrowing_book_by_user(user, book)
    find_by(user_id: user.id, book_id: book, returned_at: nil)
  end

  def self.all_borrowings_book(book)
    where(book_id: book.id).includes(:user)
  end

  def user
    User.with_deleted.find(user_id)
  end

  private

  def return_date_after_borrow_date
    errors.add(:returned_at, :is_incorrect) if returned_at.present? && returned_at < borrowed_at
  end
end
