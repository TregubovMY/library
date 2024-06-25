# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user!, only: %i[edit update destroy restore]

    def index
      @users = User.search_by_name_email_or_created_at_or_role(params[:search_query]).page(params[:page])

      respond_to do |format|
        format.html
        format.turbo_stream

        add_breadcrumb t('shared.menu.users'), admin_users_path
      end
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

      respond_to do |format|
        flash.now[:success] = t('.success')
        if @user.save
          format.html { redirect_to admin_users_path, flash: { success: t('.success') } }

          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.remove(:modal),
              turbo_stream.prepend('flash', partial: 'shared/flash')
            ]
          end
        else
          format.html { render :new }
        end
      end
    end

    def update
      respond_to do |format|
        if update_user_attributes
          flash.now[:success] = t('.success')
          format.html { redirect_to admin_users_path, flash: { success: t('.success') } }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.remove(:modal),
              turbo_stream.prepend('flash', partial: 'shared/flash')
            ]
          end
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to admin_users_path, flash: { success: t('.success') }, status: :see_other }
        format.turbo_stream
      end
    end

    def restore
      respond_to do |format|
        if @user.restore
          format.html { redirect_to admin_users_path, flash: { success: t('.success') } }
          format.turbo_stream
        else
          format.html { render :index }
        end
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
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
#
