require "lystonosha/engine"
require "lystonosha/messageable"

module Lystonosha
  # Callback called after message has been created
  mattr_accessor :message_delivered
  @@message_delivered = nil

  def self.setup
    yield self
  end
end
