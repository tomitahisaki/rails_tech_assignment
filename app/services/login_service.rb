class LoginService
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string
  attr_reader :user

  validates :email,    presence: true
  validates :password, presence: true
  validate :authenticate_user

  private

  def authenticate_user
    return if email.blank? || password.blank?

    normalized = email.to_s.strip.downcase
    @user = User.find_by(email: normalized)

    unless @user&.authenticate(password)
      errors.add(:base, "メールアドレスまたはパスワードが違います")
    end
  end
end
