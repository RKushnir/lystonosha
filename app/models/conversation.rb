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

  def mark_as_read(participant)
    Lystonosha::Messageable(participant).mark_conversation_as_read(self)
  end

  def read?
    unread_messages_count > 0
  end

  class UnreadMessagesSqlBuilder
    def self.build
      "COUNT(#{unread_messages_condition}) AS unread_messages_count"
    end

    private

    def self.unread_messages_condition
      "NULLIF(receipts.read, #{sql_false})"
    end

    def self.sql_false
      ActiveRecord::Base.connection.quoted_false
    end
  end
end
