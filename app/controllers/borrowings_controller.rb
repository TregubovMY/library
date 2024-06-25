# frozen_string_literal: true

class BorrowingsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  has_scope :search_book_by_user
  def index
    @books = apply_scopes(Borrowing)
             .search_book_by_user(current_user, params[:search_query]).page(params[:page])

    add_breadcrumb t('shared.menu.my_books'), borrowings_path
  end

  def create
    @book = Book.find(params[:book_id])
    @book, @book.id_borrowing = create_borrowing_and_update_book

    respond_to do |format|
      flash.now[:success] = t('.success')
      format.html { redirect_to book_path(@book), flash: { success: t('.success') } }
      format.turbo_stream do
        method = if params[:context] == 'single_book'
                   turbo_stream.update(@book, partial: 'books/book', locals: { book: @book })
                 else
                   turbo_stream.update(@book, partial: 'books/book_all', locals: { book: @book })
                 end

        render turbo_stream: [method, turbo_stream.prepend('flash', partial: 'shared/flash')]
      end
    end
  rescue ActiveRecord::RecordInvalid
    format.html { render 'books/show' }
  end

  def update
    @borrowing = Borrowing.includes(:book).find(params[:id])
    @borrowing = update_borrowing_and_update_book

    respond_to do |format|
      flash.now[:success] = t('.success')
      format.html { redirect_to book_path(@borrowing.book), flash: { success: t('.success') } }
      format.turbo_stream do
        method = if params[:context] == 'single_book'
                   turbo_stream.update(@borrowing.book, partial: 'books/book', locals: { book: @borrowing.book })
                 else
                   turbo_stream.update(@book, partial: 'books/book_all', locals: { book: @borrowing.book })
                 end

        render turbo_stream: [method, turbo_stream.prepend('flash', partial: 'shared/flash')]
      end
    end
  rescue ActiveRecord::RecordInvalid
    format.html { render 'books/show' }
  end

  private

  def create_borrowing_and_update_book
    Borrowing.transaction do
      @borrowing = @book.borrowings.create!(user: current_user, borrowed_at: Time.zone.now)
      @book.decrement(:available_books).save!
    end
    [@book, @borrowing]
  end

  def update_borrowing_and_update_book
    Borrowing.transaction do
      @borrowing.update!(returned_at: Time.zone.now)
      @borrowing.book.increment(:available_books).save!
    end
    @borrowing
  end
end
