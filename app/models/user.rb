class User < ApplicationRecord
  has_many :photos, dependent: :destroy

  before_save :normalize_email
  has_secure_password

validates :email, presence: true, uniqueness: true
validates :password, presence: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
