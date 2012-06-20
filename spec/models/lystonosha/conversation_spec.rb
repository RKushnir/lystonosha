require 'spec_helper'

module Lystonosha
  describe Conversation do
    describe '.find_dialog' do
      it "finds conversation with both participants" do
        participants = [create(:user), create(:user)]
        receipts = [
          Receipt.new(recipient: participants[0], mailbox: :outbox),
          Receipt.new(recipient: participants[1], mailbox: :inbox)
        ]

        message = Message.create!(subject: 'Subject',
                              body: 'Body',
                              sender: participants[0],
                              receipts: receipts)

        Conversation.find_dialogs(*participants).should include(message.conversation)
      end

      it "ignores group conversations" do
        participants = [create(:user), create(:user), create(:user)]
        receipts = [
          Receipt.new(recipient: participants[0], mailbox: :outbox),
          Receipt.new(recipient: participants[1], mailbox: :inbox),
          Receipt.new(recipient: participants[2], mailbox: :inbox)
        ]

        message = Message.create!(subject: 'Subject',
                              body: 'Body',
                              sender: participants[0],
                              receipts: receipts)

        Conversation.find_dialogs(participants[0], participants[1]).should be_empty
      end
    end
  end
end