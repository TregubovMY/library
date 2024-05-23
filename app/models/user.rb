# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  has_many :borrowings, dependent: :nullify
  has_many :books, through: :borrowings

  enum role: { user: 0, moderator: 1, admin: 2 }, _suffix: :role

  attr_accessor :admin_edit

  # has_secure_password validations: false

  # validate :password_presence
  # validate :correct_old_password, on: :update, if: -> { password.present? && !admin_edit }
  # validates :password, confirmation: true, allow_blank: true

  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true
  validates :phone, phone: true, allow_blank: true
  # validate :password_complexity

  before_save :normalize_phone

  def guest?
    false
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end
end
