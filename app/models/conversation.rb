class Conversation < ActiveRecord::Base
  attr_protected

  has_many :messages, inverse_of: :conversation, order: 'messages.created_at ASC'
  has_many :receipts, through: :messages do
    def recipients
      includes(:recipient).map(&:recipient).uniq
    end
  end

  scope :in_reverse_chronological_order, order('conversations.updated_at DESC')
  scope :with_unread_messages_count, ->() do
      joins(:receipts).
      group('conversations.id').
      select("conversations.*, #{UnreadMessagesSqlBuilder.build}")
  end

  def messages_for_participant(participant)
    messages.for_recipient(participant)
  end

  def participants
    receipts.recipients
  end

  def self.find_dialogs(participant1, participant2)
    participants = [participant1, participant2]
    Conversation.where(id: common_conversation_ids(*participants)).
                 joins(:receipts).
                 group('conversations.id').
                 having('COUNT(DISTINCT receipts.recipient_id) = 2')
  end

  def mark_as_read(participant)
    Lystonosha::Messageable(participant).mark_conversation_as_read(self)
  end

  def unread?
    unread_messages_count != 0
  end

  class UnreadMessagesSqlBuilder
    def self.build
      "COUNT(#{unread_messages_condition}) AS unread_messages_count"
    end

    private

    def self.unread_messages_condition
      "NULLIF(receipts.read, #{sql_true})"
    end

    def self.sql_true
      ActiveRecord::Base.connection.quoted_true
    end
  end

  private

  def self.common_conversation_ids(participant1, participant2)
    both_participants_belong_to_conversation = {
      receipts:          Receipt.for_recipient_conditions(participant1),
      receipts_messages: Receipt.for_recipient_conditions(participant2)
    }

    common_conversation_ids = Receipt.
      joins(message: { conversation: { messages: :receipts } }).
      where(both_participants_belong_to_conversation).
      pluck('conversations.id')
  end
end
