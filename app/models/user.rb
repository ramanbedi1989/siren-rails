class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  USER_CATEGORIES = ["sufferer", "mediator", "healer"]

  scope :active_healers, -> { where(busy: false, category: USER_CATEGORIES[2]) }

  scope :healers, -> { where(category: USER_CATEGORIES[2]) }

  scope :mediators, -> { where(category: USER_CATEGORIES[1]) }

  validates :auth_token, uniqueness: true

  before_create :generate_authentication_token!

  validate :valid_category

  has_many :sufferer_emergency_routes, :class_name => 'EmergencyRoute', :foreign_key => 'sufferer_id'

  has_many :healer_emergency_routes, :class_name => 'EmergencyRoute', :foreign_key => 'healer_id'

  has_many :locations

  def valid_category
    unless USER_CATEGORIES.include? category
      errors.add(:category, 'allowed values are #{USER_CATEGORIES.to_sentence}')
    end
  end

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token 
    end while self.class.exists?(auth_token: auth_token)
  end

  USER_CATEGORIES.each do |category|
    define_method "#{category}?".to_sym do
      self.category == category
    end
  end

end
