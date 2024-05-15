module Authentication
  extend ActiveSupport::Concern
  included do
    private

    def sign_in(user)
      session[:user_id] = user.id
    end

    def sign_out
      session.delete :user_id
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]).decorate if session[:user_id].present?
    end

    def user_sign_in?
      current_user.present?
    end

    helper_method :current_user, :user_sign_in?
  end
end
