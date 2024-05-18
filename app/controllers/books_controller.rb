# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :require_authentication, except: %i[index show]
  before_action :set_book!, only: %i[edit update destroy]
  before_action :authorize_book!
  after_action :verify_authorized

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
    params.require(:book).permit(:title, :author, :description)
  end

  def set_book!
    @book = Book.find(params[:id])
  end

  def authorize_book!
    authorize(@book || Book)
  end
end
