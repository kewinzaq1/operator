module Tools
  class MessagingTool
    ACCEPT = /\b(yep|yes|yeah|ok|okay|sure|works|tak|pasuje|dobra|jasne)\b/i
    DECLINE = /\b(no|can't|cannot|nie|sorry|won't)\b/i

    def initialize(business, provider: Providers.messaging)
      @business = business
      @provider = provider
    end

    def send_message(customer:, body:, agent_action: nil)
      raise "Customer opted out" if customer.opted_out?

      conversation = @business.conversations.find_or_create_by!(customer: customer) do |c|
        c.channel = "imessage"
        c.status = "open"
      end

      result = @provider.send_message(to: customer.phone, body: body, chat_id: conversation.external_id)
      conversation.update!(external_id: result.chat_id) if result.chat_id.present?

      conversation.messages.create!(
        direction: "outbound",
        body: body,
        provider: provider_name,
        external_id: result.external_id,
        status: result.status,
        sent_at: Time.current,
        agent_action: agent_action
      ).tap { customer.update!(last_contacted_at: Time.current) }
    end

    def receive_message(customer:, body:, external_id: nil, provider: provider_name)
      conversation = @business.conversations.find_or_create_by!(customer: customer) do |c|
        c.channel = "imessage"
        c.status = "open"
      end

      intent = detect_intent(body)
      conversation.messages.create!(
        direction: "inbound",
        body: body,
        provider: provider,
        external_id: external_id,
        status: "received",
        sent_at: Time.current,
        intent: intent
      )
    end

    def simulate_demo_reply(customer)
      return unless @provider.respond_to?(:simulate_reply)

      body = case customer.demo_behavior
      when "accept"
        "Yep, 17:00 works for me!"
      when "ignore"
        nil
      else
        nil
      end
      return unless body

      receive_message(customer: customer, body: body)
    end

    def detect_intent(body)
      return "DECLINE" if body.match?(DECLINE) && !body.match?(ACCEPT)
      return "ACCEPT" if body.match?(ACCEPT)
      "UNKNOWN"
    end

    def unanswered_accept_for(customer)
      conversation = customer.conversations.order(:id).last
      return unless conversation
      last_in = conversation.messages.inbound.order(:sent_at, :id).last
      return unless last_in&.intent == "ACCEPT"
      last_in
    end

    private

    def provider_name
      @provider.is_a?(Messaging::LinqClient) ? "linq" : "demo"
    end
  end
end
