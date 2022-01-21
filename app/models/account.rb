class Account < ApplicationRecord
  include Rodauth::Rails.model

  has_many :posts
  has_one :profile
end
