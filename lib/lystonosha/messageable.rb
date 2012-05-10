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
                          push(receipts(:outbox).new)
      message.save
    end

    def trash_message(message)
      message.receipts.merge(receipts).delete_all
    end

    def receipts(mailbox = nil)
      Receipt.where(recipient_id: id, recipient_type: self.class.name).instance_eval do
        mailbox ? where(mailbox: mailbox) : self
      end
    end

    def conversations(mailbox = nil)
      Conversation.joins(:receipts).merge(receipts(mailbox)).
                   order('conversations.updated_at DESC').
                   each do |c|
                     c.reader = self
                     c.mailbox = mailbox
                   end
    end
        c.reader = self
        c.mailbox = mailbox
      end
    end
  end
end
