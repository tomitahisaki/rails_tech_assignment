class LoginService
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string
  attr_reader :user

  validates :email,    presence: true
  validates :password, presence: true

  def execute
    return false unless valid?

    normalized = email.to_s.strip.downcase
    @user = User.find_by(email: normalized)

    if @user&.authenticate(password)
      true
    else
      errors.add(:base, "メールアドレスまたはパスワードが違います")
      false
    end
  end
end
