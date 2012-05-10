class Conversation < ActiveRecord::Base
  attr_protected
  attr_accessor :reader, :mailbox

  has_many :messages, inverse_of: :conversation, order: 'messages.created_at ASC'
  has_many :receipts, through: :messages

  def messages(*)
    return super unless reader
    super.joins(:receipts).merge(reader.receipts(mailbox))
  end

  def participants
    receipts.includes(:recipient).map(&:recipient)
  end
end
