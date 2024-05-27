# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :borrowings, dependent: :destroy
  has_many :books, through: :borrowings

  enum role: { user: 0, moderator: 1, admin: 2 }, _suffix: :role

  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true
  validates :phone, phone: true, allow_blank: true
  validate :password_complexity

  before_save :normalize_phone

  def guest_role?
    false
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/

    errors.add :password, :complexity_error
  end
end
