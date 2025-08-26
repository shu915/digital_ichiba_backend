# app/models/user_identity.rb
class UserIdentity < ApplicationRecord
  belongs_to :user

  enum :provider, { email: 0, google: 1 }, prefix: true

  validates :provider, presence: true
  validates :provider_subject, presence: true, length: { maximum: 200 }
end
