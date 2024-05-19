# frozen_string_literal: true

class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validate :return_date_after_borrow_date

  def self.borrowing_by_user(user)
    where(user_id: user.id, returned_at: nil).includes(:book)
  end

  def self.borrowing_book_by_user(user, book)
    find_by(user_id: user.id, book_id: book, returned_at: nil)
  end

  def self.all_borrowings_book(book)
    where(book_id: book.id).includes(:user)
  end

  private

  def return_date_after_borrow_date
    errors.add(:returned_at, :is_incorrect) if returned_at.present? && returned_at < borrowed_at
  end
end
