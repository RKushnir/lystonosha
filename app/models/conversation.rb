class Conversation < ActiveRecord::Base
  attr_protected
  attr_accessor :reader, :mailbox

  has_many :messages
  has_many :receipts, through: :messages

  def messages(*)
    return super unless reader
    super.joins(:receipts).merge(reader.receipts(mailbox))
  end
end
