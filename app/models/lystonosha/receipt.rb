module Lystonosha
  class Receipt < ActiveRecord::Base
    attr_protected

    belongs_to :message, inverse_of: :receipts
    belongs_to :recipient, polymorphic: true

    validates :message, :recipient, presence: true

    scope :for_recipient, ->(recipient) do
      where(for_recipient_conditions(recipient))
    end

    scope :unread, where(read: false)

    def self.for_recipient_conditions(recipient)
      { recipient_id: recipient, recipient_type: recipient.class }
    end
  end
end
