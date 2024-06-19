# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_book!, only: %i[edit update destroy show restore]
  authorize_resource

  has_scope :search_book

  def index
    @books = apply_scopes(Book)
             .search_book(params[:title_or_author], current_user&.admin_role?).page(params[:page])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(:books, partial: 'books/books', locals: { books: @books })
        ]
      end
      add_breadcrumb t('shared.menu.books'), books_path

    end
  end

  def show
    @borrowing = Borrowing.borrowing_book_by_user(current_user, @book) if current_user
    @borrowings = Borrowing.all_borrowings_book(@book).page(params[:page])

    add_breadcrumb @book.title, book_path(@book)
  end

  def new
    @book = Book.new

    add_breadcrumb t('shared.menu.new_book'), new_book_path
  end

  def edit
    add_breadcrumb @book.title, edit_book_path(@book)
  end

  def create
    @book = Book.new book_params

    respond_to do |format|
      if @book.save
        flash.now[:success] = t('.success')
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(Book.new, partial: 'books/add_new_book_btn'),
            turbo_stream.prepend(:books, partial: 'books/book', locals: { book: @book }),
            turbo_stream.prepend('flash', partial: 'shared/flash')
          ]
        end
        format.html do
          redirect_to :books, flash: t('.success')
        end
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(Book.new, partial: 'books/form', locals: { book: @book }),
          ]
        end
        format.html { render :new }
      end
    end
  end

  def update
    if @book.update book_params
      redirect_to book_path(@book)#, flash: { success: t('.success') }
    else
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @book.destroy
        format.html { redirect_to books_path, flash: { success: t('.success') } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(@book, partial: 'books/book_all', locals: { book: @book })
        end
      else
        format.html { render :show }
      end
    end

  end

  def restore
    respond_to do |format|
      if @book.restore
        format.html { redirect_to book_path(@book), flash: { success: t('.success') } }
        format.turbo_stream do

          render turbo_stream: [
            turbo_stream.update(@book, partial: 'books/book_all', locals: { book: @book }),
          ]
        end
      else
         format.html { render :show }
      end
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :description, :total_books, :available_books)
  end

  def set_book!
    @book = Book.with_deleted.find(params[:id])
    raise ActiveRecord::RecordNotFound if @book.deleted_at? && !current_user.admin_role?
  end
end
