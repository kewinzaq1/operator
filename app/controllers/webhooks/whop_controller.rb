module Webhooks
  class WhopController < ApplicationController
    skip_forgery_protection

    def create
      event = JSON.parse(request.body.read)
      Rails.logger.info("[Whop] #{event["type"]}")
      head :ok
    rescue JSON::ParserError
      head :bad_request
    end
  end
end
