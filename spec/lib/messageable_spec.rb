require 'spec_helper'

describe Lystonosha::Messageable do
  let(:sender) { Lystonosha::Messageable(create :user) }
  let(:recipients) { [Lystonosha::Messageable(create :user),
                      Lystonosha::Messageable(create :user)] }
  let(:message) { sender.compose_message(recipients: recipients,
                                         subject: 'Greeting',
                                         body: 'How are you?') }

  describe "#compose_message" do
    it "builds a new message" do
      message.recipients.should == recipients
      message.subject.should == 'Greeting'
      message.body.should == 'How are you?'
    end

    it "builds a reply to conversation" do
      message.deliver
      conversation = message.conversation
      reply_message = recipients[0].compose_message(conversation: conversation,
                                                    body: 'How are you?')
      Set.new(reply_message.recipients).should == Set[sender, *recipients[1..-1]]
    end
  end

  describe "#deliver_message" do
    context "when successful" do
      it "returns true" do
        sender.deliver_message(message).should be_true
      end

      it "creates conversation in sender's outbox" do
        sender.deliver_message(message)
        sender.outbox.first.should == message.conversation
      end

      it "creates conversations in recipients' inboxes" do
        sender.deliver_message(message)
        recipients.each {|r| r.inbox.first.should == message.conversation }
      end

      it "sets subject for the new conversation" do
        sender.deliver_message(message)
        sender.outbox.first.subject.should == message.subject
      end

      it "touches the conversation" do
        sender.deliver_message(message)
        conversation = message.conversation
        last_update_time = conversation.updated_at - 1
        conversation.update_attribute(:updated_at, last_update_time)
        reply = sender.compose_message(conversation: conversation, body: 'Reply')
        sender.deliver_message(reply)
        conversation.updated_at.should_not == last_update_time
      end
    end
  end

  describe "#trash" do
    let(:participant1) { recipients[0] }
    let(:participant2) { recipients[1] }

    before do
      message.deliver
      participant1.trash(message)
    end

    it "removes message from participant's mailbox" do
      participant1.inbox.should be_empty
    end

    it "does not remove message from other participants' mailboxes" do
      participant2.inbox.first.messages.should include(message)
    end
  end

  describe "#conversations" do
    let(:participant1) { Lystonosha::Messageable(create :user) }
    let(:participant2) { Lystonosha::Messageable(create :user) }
    let(:message1) { participant1.compose_message(recipients: [participant2],
                                                  subject: 'Greeting',
                                                  body: 'How are you?') }
    let(:message2) { participant2.compose_message(recipients: [participant1],
                                                  subject: 'Greeting',
                                                  body: 'How are you?') }
    before do
      message1.deliver
      message2.deliver
    end

    it "returns conversations for mailbox" do
      participant1.conversations(:inbox).should == [message2.conversation]
      participant1.conversations(:outbox).should == [message1.conversation]
    end

    it "sets `unread` flag for conversations" do
      participant1.conversations(:inbox).first.should be_unread
      participant1.mark_as_read(participant1.conversations(:inbox).first)
      participant1.conversations(:inbox).first.should_not be_unread
    end
  end

  describe "#mark_as_read" do
    let(:participant) { recipients[0] }

    it "marks message as read" do
      message.deliver
      participant.mark_as_read(message)
      participant.read?(message).should be_true
    end

    it "marks conversation as read" do
      message.deliver
      participant.mark_as_read(message.conversation)
      participant.read?(message.conversation).should be_true
      message.conversation.messages.each do |m|
        participant.read?(m).should be_true
      end
    end
  end

  describe "#unread_messages_count" do
    it "gives the count of unread messages" do
      message = sender.compose_message(recipients: recipients,
                             subject: 'Greeting',
                             body: 'How are you?')
      message.deliver
      sender.compose_message(conversation: message.conversation,
                             body: 'How do you do?').deliver
      recipients[0].unread_messages_count.should == 2
    end
  end
end
