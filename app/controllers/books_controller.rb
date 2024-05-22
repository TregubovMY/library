# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :require_authentication, except: %i[index show]
  before_action :set_book!, only: %i[edit update destroy show]
  before_action :authorize_book!
  after_action :verify_authorized

  has_scope :search_book

  def index
    @books = apply_scopes(Book).search_book(params[:title], params[:author]).page(params[:page])

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
      flash[:success] = t('.success')
      redirect_to books_path
    else
      render :new
    end
  end

  def update
    if @book.update book_params
      flash[:success] = t('.success')
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  def destroy
    @book.destroy
    flash[:success] = t('.success')
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :description, :total_books)
  end

  def set_book!
    @book = Book.find(params[:id])
  end

  def authorize_book!
    authorize(@book || Book)
  end
end
