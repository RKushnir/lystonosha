class Conversation < ActiveRecord::Base
  attr_protected

  has_many :messages, inverse_of: :conversation, order: 'messages.created_at ASC'
  has_many :receipts, through: :messages do
    def recipients
      includes(:recipient).map(&:recipient).uniq
    end
  end

  scope :in_reverse_chronological_order, order('conversations.updated_at DESC')

  def messages_for_participant(participant)
    messages.for_recipient(participant)
  end

  def participants
    receipts.recipients
  end

  def mark_as_read(participant)
    Lystonosha::Messageable(participant).mark_conversation_as_read(self)
  end
end
