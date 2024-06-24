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

  after_create_commit lambda {
                        broadcast_prepend_later_to :users, partial: 'admin/users/user', locals: { user: self }
                      }

  after_update_commit lambda {
                        broadcast_replace_later_to :users, partial: 'admin/users/user', locals: { user: self }
                      }

  after_destroy_commit lambda {
                         broadcast_replace_later_to :users, partial: 'admin/users/user', locals: { user: self }
                       }

  scope :search_by_name_email_or_created_at_or_role, (lambda do |query = nil|
    if query.present?
      role_value = roles[query.downcase.to_sym] if roles.key?(query.downcase.to_sym)
      where('name ILIKE :query OR email ILIKE :query OR created_at::text ILIKE :query OR role = :role_value',
            query: "%#{query}%", role_value:)
    else
      all
    end
  end)

  def restore(options = {})
    super(options)
    broadcast_replace_later_to :users, partial: 'admin/users/user', locals: { user: self }
  end

  def guest_role?
    false
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

  def password_complexity
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/

    errors.add :password, :complexity_error
  end
end
