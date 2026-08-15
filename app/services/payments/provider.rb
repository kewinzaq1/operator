module Payments
  class Provider
    Session = Struct.new(:id, :url, :status, :raw, keyword_init: true)

    def create_checkout_session(payment:, success_url:, cancel_url:)
      raise NotImplementedError
    end

    def refund(payment:, amount:)
      raise NotImplementedError
    end
  end
end
