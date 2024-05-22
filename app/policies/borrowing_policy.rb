# frozen_string_literal: true

class BorrowingPolicy < ApplicationPolicy
  def create?
    user.user_role?
  end

  def update?
    user.user_role?
  end

  def destroy?
    false
  end

  def index?
    user.user_role?
  end

  def show?
    false
  end
end
