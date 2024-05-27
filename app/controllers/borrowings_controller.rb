# frozen_string_literal: true

class BorrowingsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  has_scope :search_book_by_user
  def index
    @books = apply_scopes(Borrowing)
             .search_book_by_user(current_user, params[:title], params[:author]).page(params[:page])

    add_breadcrumb t('shared.menu.my_books'), borrowings_path
  end

  def create
    @book = Book.find(params[:book_id])
    create_borrowing_and_update_book
    redirect_to book_path(@book), flash: { success: t('.success') }
  rescue ActiveRecord::RecordInvalid
    render 'books/show'
  end

  def update
    @borrowing = Borrowing.find(params[:id])
    update_borrowing_and_update_book
    redirect_to book_path(@borrowing.book), flash: { success: t('.success') }
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
end
