class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:email]
    if user&.authenticate(params[:password])
      do_sign_in user
    else
      flash.now[:warning] = 'Incorrect email and/or password!'
      render :new
    end
  end

  def destroy
    sign_out
    flash[:success] = "You've been signed out!"
    redirect_to root_path
  end
end
