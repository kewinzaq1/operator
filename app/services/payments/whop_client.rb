module Payments
  # Secondary channel for digital programs / memberships. Stripe remains primary for sessions.
  class WhopClient
    BASE = "https://api.whop.com/api/v1"

    def initialize(api_key: ENV["WHOP_API_KEY"], company_id: ENV["WHOP_COMPANY_ID"])
      @company_id = company_id
      @http = HttpJson.new(base_url: BASE, headers: { "Authorization" => "Bearer #{api_key}" })
    end

    def list_products
      @http.get("products?company_id=#{@company_id}")
    end

    def create_checkout(plan_id:)
      @http.post("checkout_configurations", { plan_id: plan_id, company_id: @company_id })
    end
  end

  class WhopDemoClient
    def list_products
      { "data" => [ { "id" => "prod_demo_home", "name" => "4-week home program" } ] }
    end

    def create_checkout(plan_id:)
      { "id" => "chk_demo", "purchase_url" => "https://whop.com/checkout/demo" }
    end
  end
end
