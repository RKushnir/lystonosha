class Receipt < ActiveRecord::Base
  attr_protected

  belongs_to :message, inverse_of: :receipts
  belongs_to :recipient, polymorphic: true

  validates :message, :recipient, presence: true
end
