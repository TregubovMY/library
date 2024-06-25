# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
class BooksController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_book!, only: %i[edit update destroy show restore]
  authorize_resource

  has_scope :search_book

  def index
    @books = Book.search_book(params[:search_query], current_user&.admin_role?).page(params[:page])

    @books.each do |book|
      book.id_borrowing = book.decorate.current_user_take?(current_user)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
      add_breadcrumb t('shared.menu.books'), books_path
    end
  end

  def show
    @book.id_borrowing = @book.decorate.current_user_take?(current_user)
    @borrowings = Borrowing.search_by_user(@book.id, params[:search_query]).page(params[:page]).per(5)

    add_breadcrumb @book.title, book_path(@book)
  end

  def new
    @book = Book.new

    add_breadcrumb t('shared.menu.new_book'), new_book_path
  end

  def edit
    add_breadcrumb @book.title, edit_book_path(@book)
    render 'books/edit', locals: { context: params[:context] }
  end

  def create
    @book = Book.new book_params

    respond_to do |format|
      if @book.save
        @book.id_borrowing = @book.decorate.current_user_take?(current_user)
        flash.now[:success] = t('.success')
        format.turbo_stream
        format.html { redirect_to :books, flash: t('.success') }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(Book.new,
                                                   partial: 'books/form', locals: { book: @book })
        end
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @book.update book_params
        @book.id_borrowing = @book.decorate.current_user_take?(current_user)
        format.html { redirect_to book_path(@book), flash: { success: t('.success') } }
        format.turbo_stream
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @book.destroy
        format.html { redirect_to books_path, flash: { success: t('.success') } }
        format.turbo_stream
      else
        format.html { render :show }
      end
    end
  end

  def restore
    respond_to do |format|
      if @book.restore
        format.html { redirect_to book_path(@book), flash: { success: t('.success') } }
        format.turbo_stream
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
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
#
