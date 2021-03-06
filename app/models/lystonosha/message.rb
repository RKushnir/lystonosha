module Lystonosha
  class Message < ActiveRecord::Base
    attr_accessible :body, :conversation, :conversation_id, :receipts,
      :recipients, :sender, :sender_id, :sender_type, :subject
    attr_accessor :recipients
    belongs_to :conversation, inverse_of: :messages, touch: true
    belongs_to :sender, polymorphic: true
    has_many :receipts, inverse_of: :message

    validates :conversation, :sender, presence: true
    validate :subject_or_body_present
    validate :at_least_one_recipient_present

    scope :for_recipient, ->(recipient) do
      joins(:receipts).merge(recipient.receipts)
    end

    def initialize(*)
      super
      self.recipients ||= []

      if conversation
        self.recipients = conversation.participants - [sender]
      else
        if recipients.one?
          self.conversation = find_conversation_by_recipient(recipients.first)
        end

        unless conversation
          build_conversation(subject: subject)
        end
      end
    end

    def deliver
      Lystonosha::Messageable(sender).deliver_message(self)
    end

    def trash(recipient)
      Lystonosha::Messageable(recipient).trash_message(self)
    end

    def mark_as_read(recipient)
      Lystonosha::Messageable(recipient).mark_message_as_read(self)
    end

    def mark_as_unread(recipient)
      Lystonosha::Messageable(recipient).mark_message_as_unread(self)
    end

    private

    def subject_or_body_present
      unless subject? || body?
        errors.add(:base, 'Either subject or body should be specified')
      end
    end

    def at_least_one_recipient_present
      unless receipts.any? {|r| r.recipient != sender }
        errors.add(:base, 'At least one recipient should be specified')
      end
    end

    def find_conversation_by_recipient(recipient)
      Conversation.find_dialogs(sender, recipient).first
    end
  end
end
