# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user!, only: %i[edit update destroy restore]

    def index
      @users = User.with_deleted.order(created_at: :desc).page(params[:page])

      add_breadcrumb t('shared.menu.users'), admin_users_path
    end

    def new
      @user = User.new

      add_breadcrumb t('shared.menu.create_user'), new_admin_user_path
    end

    def edit; end

    def create
      @user = User.new user_params
      @user.skip_confirmation!

      if @user.save
        flash[:success] = t('.success')
        redirect_to admin_users_path
      else
        render :new
      end
    end

    def update
      if update_user_attributes
        flash[:success] = t '.success'
        redirect_to admin_users_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      flash[:success] = t '.success'
      redirect_to admin_users_path, status: :see_other
    end

    def restore
      if @user.restore
        flash[:success] = t('.success')
        redirect_to admin_users_path
      else
        render :index
      end
    end

    private

    def update_user_attributes
      @user.skip_reconfirmation!

      if params[:user][:password].blank?
        @user.update_without_password(user_params)
      else
        @user.update(user_params)
      end
    end

    def set_user!
      @user = User.with_deleted.find params[:id]
    end

    def user_params
      params.require(:user).permit(
        :email, :phone, :name, :password, :password_confirmation, :role
      )
    end
  end
end
