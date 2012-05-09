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
      transaction do
        return false unless message.save
        store_message(message, :outbox)
        Lystonosha::Messageable(message.recipients).each {|r| r.store_message(message, :inbox) }
        true
      end
    end

    def trash_message(message)
      message.receipts.merge(receipts).delete_all
    end

    def store_message(message, mailbox)
      message.receipts.merge(receipts(mailbox)).create!
    end

    def receipts(mailbox = nil)
      Receipt.where(recipient_id: id, recipient_type: self.class.name).instance_eval do
        mailbox ? where(mailbox: mailbox) : self
      end
    end

    private

    def conversations(mailbox)
      Conversation.joins(:receipts).merge(receipts(mailbox)).each do |c|
        c.reader = self
        c.mailbox = mailbox
      end
    end
  end
end
