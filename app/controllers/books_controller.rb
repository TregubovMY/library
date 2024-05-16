# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :set_book!, only: %i[edit update destroy]

  def index
    @pagy, @books = pagy Book.all
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def edit; end

  def create
    @book = Book.new book_params

    if @book.save
      flash[:success] = 'Book created!'
      redirect_to books_path
    else
      render :new
    end
  end

  def update
    if @book.update book_params
      flash[:success] = 'Book updated!'
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  def destroy
    @book.destroy
    flash[:success] = 'Book deleted!'
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :description)
  end

  def set_book!
    @book = Book.find(params[:id])
  end
end
