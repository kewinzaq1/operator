module Webhooks
  class LinqController < ApplicationController
    skip_forgery_protection

    OPT_OUT = /\A(STOP|UNSUBSCRIBE|OPTOUT|CANCEL|END|QUIT)\z/i

    def create
      event = JSON.parse(request.body.read)
      type = event["type"] || event["event"]
      data = event["data"] || event["message"] || event

      if type.to_s.include?("message.received") || data["direction"] == "inbound"
        body = data.dig("parts", 0, "value") || data["body"] || data["text"]
        from = data["from"] || data["author"]
        customer = Customer.find_by(phone: from)
        if customer
          if body.to_s.strip.match?(OPT_OUT)
            customer.update!(opted_out: true)
          else
            Tools::MessagingTool.new(customer.business).receive_message(
              customer: customer,
              body: body,
              external_id: data["id"],
              provider: "linq"
            )
          end
        end
      end

      head :ok
    rescue JSON::ParserError
      head :bad_request
    end
  end
end
