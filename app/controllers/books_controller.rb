# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_book!, only: %i[edit update destroy show restore]
  authorize_resource

  has_scope :search_book

  def index
    @books = apply_scopes(Book)
             .search_book(params[:title_or_author], current_user&.admin_role?).page(params[:page])

    add_breadcrumb t('shared.menu.books'), books_path
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

    if @book.save
      flash.now[:success] = t('.success')
    else
      render :new
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
    if @book.destroy
      redirect_to books_path, flash: { success: t('.success') }
    else
      render :show
    end
  end

  def restore
    if @book.restore
      redirect_to book_path(@book), flash: { success: t('.success') }
    else
      render :show
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :description, :total_books, :title_or_author)
  end

  def set_book!
    @book = Book.with_deleted.find(params[:id])
    raise ActiveRecord::RecordNotFound if @book.deleted_at? && !current_user.admin_role?
  end
end
