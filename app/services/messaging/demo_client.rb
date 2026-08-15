module Messaging
  class DemoClient < Provider
    def send_message(to:, body:, chat_id: nil)
      Result.new(
        external_id: "linq_demo_#{SecureRandom.hex(6)}",
        chat_id: chat_id.presence || "chat_demo_#{to.to_s.gsub(/\W/, '')}",
        status: "sent",
        raw: { "service" => "iMessage", "demo" => true, "to" => to, "body" => body }
      )
    end

    def simulate_reply(body:)
      Result.new(
        external_id: "linq_demo_in_#{SecureRandom.hex(6)}",
        chat_id: nil,
        status: "received",
        raw: { "body" => body, "demo" => true }
      )
    end
  end
end
