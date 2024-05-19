# frozen_string_literal: true

class BorrowingsController < ApplicationController
  before_action :require_authentication
  before_action :authorize_borrowing!
  after_action :verify_authorized

  def index
    @pagy, borrowings = pagy(Borrowing.borrowing_by_user(current_user))
    @books = borrowings.map(&:book)
  end

  def create
    @book = Book.find(params[:book_id])
    create_borrowing_and_update_book
    flash[:success] = t('.success')
    redirect_to book_path(@book)
  rescue ActiveRecord::RecordInvalid
    render 'books/show'
  end

  def update
    @borrowing = Borrowing.find(params[:id])
    update_borrowing_and_update_book
    flash[:success] = t('.success')
    redirect_to book_path(@borrowing.book)
  rescue ActiveRecord::RecordInvalid
    render 'books/show'
  end

  private

  def create_borrowing_and_update_book
    Borrowing.transaction do
      @borrowing = @book.borrowings.create!(user: current_user, borrowed_at: Time.zone.now)
      @book.decrement(:available_books).save!
    end
  end

  def update_borrowing_and_update_book
    Borrowing.transaction do
      @borrowing.update!(returned_at: Time.zone.now)
      @borrowing.book.increment(:available_books).save!
    end
  end

  def authorize_borrowing!
    authorize(@borrowing || Borrowing)
  end
end
