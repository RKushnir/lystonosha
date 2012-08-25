module Lystonosha
  class Conversation < ActiveRecord::Base
    attr_protected

    has_many :messages, inverse_of: :conversation,
      order: Message.arel_table[:created_at].asc
    has_many :receipts, through: :messages do
      def recipients
        includes(:recipient).map(&:recipient).uniq
      end
    end

    scope :in_reverse_chronological_order, order(arel_table[:updated_at].desc)

    def self.with_unread_messages_count
      receipts = Receipt.arel_table
      unread_messages_count = count_null_if(receipts[:read], true).
        as('unread_messages_count')

      joins(:receipts).
      group('lystonosha_conversations.id').
      select_with_self(unread_messages_count)
    end

    def messages_for_participant(participant)
      messages.for_recipient(participant)
    end

    def participants
      receipts.recipients
    end

    def self.find_dialogs(participant1, participant2)
      receipts = Receipt.arel_table
      participants = [participant1, participant2]

      where(id: common_conversation_ids(*participants)).
      joins(:receipts).
      group('lystonosha_conversations.id').
      having(receipts[:recipient_id].count(true).eq(2))
    end

    def mark_as_read(participant)
      Lystonosha::Messageable(participant).mark_conversation_as_read(self)
    end

    def unread?
      unread_messages_count != 0
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

    def self.select_with_self(extra_columns)
      select([arel_table[Arel.star], extra_columns].flatten)
    end

    def self.count_null_if(expression1, expression2)
      sql_function = Arel::Nodes::NamedFunction
      null_if = sql_function.new("NULLIF", [expression1, expression2])
      sql_function.new("COUNT", [null_if])
    end
  end
end
