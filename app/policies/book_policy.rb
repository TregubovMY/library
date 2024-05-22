# frozen_string_literal: true

class BookPolicy < ApplicationPolicy
  def create?
    user.admin_role? || user.moderator_role?
  end

  def update?
    user.admin_role? || user.moderator_role?
  end

  def destroy?
    user.admin_role? || user.moderator_role?
  end

  def index?
    true
  end

  def show?
    true
  end
end
