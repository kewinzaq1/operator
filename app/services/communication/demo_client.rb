module Communication
  class DemoClient
    def publish(body, type: "thought")
      Rails.logger.info("[Band:demo] #{type}: #{body}")
      { "demo" => true, "content" => body, "message_type" => type }
    end

    def ensure_room
      "chat_demo_ops"
    end
  end
end
