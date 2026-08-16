module Providers
  module_function

  def demo_mode?
    Rails.application.config.demo_mode || false
  end

  def messaging
    if demo_mode? || ENV["LINQ_API_TOKEN"].blank?
      Messaging::DemoClient.new
    else
      Messaging::LinqClient.new
    end
  end

  def payments
    if ENV["STRIPE_PAYMENT_LINK_URL"].present?
      Payments::PaymentLinkClient.new
    elsif demo_mode? || ENV["STRIPE_SECRET_KEY"].blank?
      Payments::DemoClient.new
    else
      Payments::StripeClient.new
    end
  end

  def humans
    if ENV["TERAC_API_KEY"].present?
      Humans::TeracClient.new
    elsif demo_mode?
      Humans::DemoClient.new
    else
      Humans::DemoClient.new
    end
  end

  def band
    if demo_mode? || ENV["BAND_API_KEY"].blank?
      Communication::DemoClient.new
    else
      Communication::BandClient.new
    end
  end

  def sandbox
    if demo_mode? || ENV["SUPERSERVE_API_KEY"].blank?
      Agents::LocalSandbox.new
    else
      Agents::SuperserveSandbox.new
    end
  end

  def whop
    if demo_mode? || ENV["WHOP_API_KEY"].blank?
      Payments::WhopDemoClient.new
    else
      Payments::WhopClient.new
    end
  end

  def replay
    Qa::ReplayClient.new
  end
end
