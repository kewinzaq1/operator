module Communication
  # Band Agent API — REST commands for the operations room.
  # Base: https://app.band.ai/api/v1/agent
  # Auth: X-API-Key
  # Events (thoughts / tool results) go to POST /chats/:id/events
  class BandClient
    BASE = "https://app.band.ai/api/v1/agent"

    def initialize(api_key: ENV["BAND_API_KEY"], chat_id: ENV["BAND_CHAT_ID"], http: nil)
      @chat_id = chat_id
      @http = http || HttpJson.new(base_url: BASE, headers: { "X-API-Key" => api_key })
    end

    def publish(body, type: "thought")
      return unless @chat_id.present?
      @http.post("chats/#{@chat_id}/events", {
        event: {
          content: body,
          message_type: type,
          metadata: { source: "operator" }
        }
      })
    rescue HttpJson::Error => e
      Rails.logger.warn("[Band] #{e.message}")
      nil
    end

    def ensure_room
      return @chat_id if @chat_id.present?
      payload = @http.post("chats", {})
      @chat_id = payload["id"] || payload.dig("chat", "id")
    end
  end
end
