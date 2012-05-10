require 'spec_helper'

describe Lystonosha::Messageable do
  let(:sender) { Lystonosha::Messageable(create :user) }
  let(:recipients) { [Lystonosha::Messageable(create :user),
                      Lystonosha::Messageable(create :user)] }
  let(:message) { sender.compose_message(recipients: recipients,
                                         subject: 'Greeting',
                                         body: 'How are you?') }

  describe "#compose_message" do
    it "builds a message" do
      message.recipients.should == recipients
      message.subject.should == 'Greeting'
      message.body.should == 'How are you?'
    end
  end

  describe "#deliver_message" do
    context "when successful" do
      it "returns true" do
        sender.deliver_message(message).should be_true
      end

      it "creates conversation in sender's outbox" do
        sender.deliver_message(message)
        sender.outbox.last.should == message.conversation
      end

      it "creates conversations in recipients' inboxes" do
        sender.deliver_message(message)
        recipients.each {|r| r.inbox.last.should == message.conversation }
      end

      it "sets subject for the new conversation" do
        sender.deliver_message(message)
        sender.outbox.last.subject.should == message.subject
      end
    end
  end

  describe "#trash_message" do
    let(:participant1) { recipients[0] }
    let(:participant2) { recipients[1] }

    before do
      message.deliver
      participant1.trash_message(message)
    end

    it "removes message from participant's mailbox" do
      participant1.inbox.should be_empty
    end

    it "does not remove message from other participants' mailboxes" do
      participant2.inbox.last.messages.should include(message)
    end
  end

  describe "#inbox" do
    let(:participant1) { Lystonosha::Messageable(create :user) }
    let(:participant2) { Lystonosha::Messageable(create :user) }

    it "returns conversations with incoming messages" do
      message1 = participant1.compose_message(recipients: [participant2],
                                              subject: 'Greeting',
                                              body: 'How are you?')
      message1.deliver
      message2 = participant2.compose_message(recipients: [participant1],
                                              subject: 'Greeting',
                                              body: 'How are you?')
      message2.deliver
      participant1.inbox.should == [message2.conversation]
    end
  end

  describe "#outbox" do
    let(:participant1) { Lystonosha::Messageable(create :user) }
    let(:participant2) { Lystonosha::Messageable(create :user) }

    it "returns conversations with incoming messages" do
      message1 = participant1.compose_message(recipients: [participant2],
                                              subject: 'Greeting',
                                              body: 'How are you?')
      message1.deliver
      message2 = participant2.compose_message(recipients: [participant1],
                                              subject: 'Greeting',
                                              body: 'How are you?')
      message2.deliver
      participant1.outbox.should == [message1.conversation]
    end
  end
end
