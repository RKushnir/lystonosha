module Lystonosha
  class Conversation < ActiveRecord::Base
    attr_protected

    has_many :messages, inverse_of: :conversation, order: 'lystonosha_messages.created_at ASC'
    has_many :receipts, through: :messages do
      def recipients
        includes(:recipient).map(&:recipient).uniq
      end
    end

    scope :in_reverse_chronological_order, order('lystonosha_conversations.updated_at DESC')
    scope :with_unread_messages_count, ->() do
        joins(:receipts).
        group('lystonosha_conversations.id').
        select("lystonosha_conversations.*, #{UnreadMessagesSqlBuilder.build}")
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
                   group('lystonosha_conversations.id').
                   having('COUNT(DISTINCT lystonosha_receipts.recipient_id) = 2')
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
        "NULLIF(lystonosha_receipts.read, #{sql_true})"
      end

      def self.sql_true
        ActiveRecord::Base.connection.quoted_true
      end
    end

    private

    def self.common_conversation_ids(participant1, participant2)
      both_participants_belong_to_conversation = {
        lystonosha_receipts:          Receipt.for_recipient_conditions(participant1),
        receipts_lystonosha_messages: Receipt.for_recipient_conditions(participant2)
      }

      common_conversation_ids = Receipt.
        joins(message: { conversation: { messages: :receipts } }).
        where(both_participants_belong_to_conversation).
        pluck('lystonosha_conversations.id')
    end
  end
end
