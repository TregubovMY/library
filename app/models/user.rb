# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :books, through: :borrowings

  enum role: { user: 0, moderator: 1, admin: 2 }, _suffix: :role

  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true
  validates :phone, phone: true, allow_blank: true

  before_save :normalize_phone

  def guest_role?
    false
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end
end
