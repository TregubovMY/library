class BookDecorator < Draper::Decorator
  delegate_all

  def current_user_take?(current_user)
    borrowing = object.borrowings.find_by(user_id: current_user.id, returned_at: nil)
    borrowing&.id
  end
end
