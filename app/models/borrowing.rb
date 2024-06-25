# frozen_string_literal: true

class Borrowing < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, -> { with_deleted }, inverse_of: :borrowings
  belongs_to :book, -> { with_deleted }, inverse_of: :borrowings

  validate :return_date_after_borrow_date

  after_create_commit lambda {
    broadcast_prepend_to :borrowings
  }
  after_update_commit lambda {
    broadcast_replace_later_to :borrowings
  }

  scope :search_book_by_user, (lambda do |user, title_or_author = nil|
    query = borrowing_by_user(user)
    if title_or_author.present?
      query = query.where('title ILIKE :query OR author ILIKE :query', query: "%#{title_or_author}%")
    end
    query
  end)

  scope :search_by_user, (lambda do |book_id, query = nil|
    if query.present?
      joins(:user).where(
        'borrowings.book_id = :book_id AND
                        (users.name ILIKE :query OR
                        users.email ILIKE :query OR
                        borrowings.borrowed_at::text ILIKE :query OR
                        borrowings.returned_at::text ILIKE :query)',
        book_id:,
        query: "%#{query}%"
      )
    else
      where(book_id:)
    end
  end)

  def self.borrowing_by_user(user)
    select('books.*, book_id').where(user_id: user.id, returned_at: nil).joins(:book)
  end

  def self.borrowing_book_by_user(user, book)
    find_by(user_id: user.id, book_id: book, returned_at: nil)
  end

  def self.all_borrowings_book(book)
    with_deleted.where(book_id: book.id).includes(:user)
  end

  private

  def return_date_after_borrow_date
    errors.add(:returned_at, :is_incorrect) if returned_at.present? && returned_at < borrowed_at
  end
end
