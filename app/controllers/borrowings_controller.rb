# frozen_string_literal: true

class BorrowingsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  has_scope :search_book_by_user
  def index
    @books = apply_scopes(Borrowing)
             .search_book_by_user(current_user, params[:title_or_author]).page(params[:page])

    add_breadcrumb t('shared.menu.my_books'), borrowings_path
  end

  def create
    @book = Book.find(params[:book_id])
    @book, @book.id_borrowing = create_borrowing_and_update_book

    respond_to do |format|
      format.html { redirect_to book_path(@book), flash: { success: t('.success') } }
      format.turbo_stream do
        method = case params[:context]
                 when 'all_books'
                   turbo_stream.update(@book, partial: 'books/book_all', locals: { book: @book})
                 when 'single_book'
                   turbo_stream.update(@book, partial: 'books/book', locals: { book: @book })
                 end

        render turbo_stream: [method,
                              turbo_stream.append(:borrowings,
                                                  partial: 'borrowings/borrowing', locals: { borrowing: @book.id_borrowing })
                             ]
      end
    end
  rescue ActiveRecord::RecordInvalid
    format.html { render 'books/show' }
  end

  def update
    @borrowing = Borrowing.includes(:book).find(params[:id])
    @borrowing = update_borrowing_and_update_book

    respond_to do |format|
      format.html { redirect_to book_path(@borrowing.book), flash: { success: t('.success') } }
      format.turbo_stream do
        method = case params[:context]
                 when 'all_books'
                   turbo_stream.update(@borrowing.book, partial: 'books/book_all', locals: { book: @borrowing.book })
                 when 'single_book'
                   turbo_stream.update(@borrowing.book, partial: 'books/book', locals: { book: @borrowing.book })
                 when 'taked_books'
                   turbo_stream.remove("borrowing_#{@borrowing.book.id}")
                 end

        render turbo_stream: [method,
                              turbo_stream.update(@borrowing,
                                                  partial: 'borrowings/borrowing', locals: { borrowing: @borrowing })
        ]
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
