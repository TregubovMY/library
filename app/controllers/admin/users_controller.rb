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

    def edit
      add_breadcrumb t('users.edit.title'), edit_admin_user_path
    end

    def create
      @user = User.new user_params
      @user.skip_confirmation!

      if @user.save
        redirect_to admin_users_path, flash: { success: t('.success') }
      else
        render :new
      end
    end

    def update
      if update_user_attributes
        redirect_to admin_users_path, flash: { success: t('.success') }
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, flash: { success: t('.success') }, status: :see_other
    end

    def restore
      if @user.restore
        redirect_to admin_users_path, flash: { success: t('.success') }
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
      @user = User.with_deleted.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :email, :phone, :name, :password, :password_confirmation, :role
      )
    end
  end
end
