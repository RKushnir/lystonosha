class Message < ActiveRecord::Base
  attr_protected
  attr_accessor :recipients
  belongs_to :conversation
  belongs_to :sender, polymorphic: true
  has_many :receipts
  has_many :recipients, through: :receipts

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
end
