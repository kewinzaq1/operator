module Messaging
  class Provider
    Result = Struct.new(:external_id, :chat_id, :status, :raw, keyword_init: true)

    def send_message(to:, body:, chat_id: nil)
      raise NotImplementedError
    end
  end
end
