class Message < ActiveRecord::Base
  attr_protected
  attr_accessor :recipients
  belongs_to :conversation, inverse_of: :messages
  belongs_to :sender, polymorphic: true
  has_many :receipts, inverse_of: :message

  validates :conversation, :sender, presence: true
  validate :subject_or_body_present
  validate :at_least_one_recipient_present

  def initialize(*)
    super
    self.conversation ||= build_conversation(subject: subject)
  end

  def deliver
    sender.deliver_message(self)
  end

  def trash(participant)
    participant.trash_message(self)
  end

  private

  def subject_or_body_present
    errors.add(:base, 'Either subject or body should be specified') unless subject? || body?
  end

  def at_least_one_recipient_present
    unless recipients.is_a?(Array) && recipients.any?
      errors.add(:recipients, 'At least one recipient should be specified')
    end
  end
end
