module Messaging
  # Linq Partner API v3 — iMessage / RCS / SMS.
  # Docs: POST https://api.linqapp.com/api/partner/v3/messages
  # Auth: Authorization: Bearer <token>
  # Send with `to` and no `from` so Linq selects the line.
  class LinqClient < Provider
    BASE = "https://api.linqapp.com/api/partner/v3"

    def initialize(token: ENV["LINQ_API_TOKEN"], http: nil)
      @token = token
      @http = http || HttpJson.new(base_url: BASE, headers: { "Authorization" => "Bearer #{token}" })
    end

    def send_message(to:, body:, chat_id: nil)
      payload = if chat_id.present?
        @http.post("chats/#{chat_id}/messages", { parts: [ { type: "text", value: body } ] })
      else
        @http.post("messages", {
          to: Array(to),
          message: { parts: [ { type: "text", value: body } ] }
        })
      end

      message = payload["message"] || payload
      Result.new(
        external_id: message["id"] || payload["id"],
        chat_id: payload["chat_id"] || chat_id,
        status: "sent",
        raw: payload
      )
    end
  end
end
