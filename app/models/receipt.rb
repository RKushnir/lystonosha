class Receipt < ActiveRecord::Base
  attr_protected

  belongs_to :recipient, polymorphic: true
  belongs_to :message
end
