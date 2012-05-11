module Lystonosha
  def self.Messageable(actor)
    case actor
    when ActiveRecord::Base then actor.extend Messageable
    when Array then actor.map {|a| Messageable(a) }
    else actor
    end
  end

  module Messageable
    def inbox
      conversations(:inbox)
    end

    def outbox
      conversations(:outbox)
    end

    def compose_message(params={})
      Message.new(params.merge(sender: self))
    end

    def deliver_message(message)
      message.receipts = Lystonosha::Messageable(message.recipients).
                          map {|r| r.receipts(:inbox).new }.
                          push(receipts(:outbox).new(read: true))
      message.save
    end

    # item can be conversation or message
    def trash(item)
      receipts_for_item(item).delete_all
    end
    alias_method :trash_message, :trash
    alias_method :trash_conversation, :trash

    # item can be conversation or message
    def mark_as_read(item)
      receipts_for_item(item).update_all(read: true)
    end
    alias_method :mark_message_as_read, :mark_as_read
    alias_method :mark_conversation_as_read, :mark_as_read

    def mark_message_as_unread(message)
      receipts_for_item(message).update_all(read: false)
    end

    def read?(item)
      receipts_for_item(item).unread.empty?
    end

    def receipts(mailbox = :all)
      Receipt.for_recipient(self).instance_eval do
        mailbox == :all ? self : where(mailbox: mailbox)
      end
    end

    def conversations(mailbox = :all)
      Conversation.uniq.in_reverse_chronological_order.
                   joins(:receipts).merge(receipts(mailbox))
    end

    def conversation(id)
      conversations.find(id)
    end

    private

    def receipts_for_item(item)
      item.receipts.merge(receipts)
    end
  end
end
