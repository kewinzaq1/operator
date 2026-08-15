class PaymentsController < ApplicationController
  def success
    if params[:payment_id].present?
      payment = Payment.find_by(id: params[:payment_id])
      Payments::WebhookHandler.mark_paid!(payment) if payment&.unpaid?
    end
    redirect_to dashboard_path, notice: "Payment recorded."
  end

  def cancel
    redirect_to dashboard_path, notice: "Payment not completed."
  end
end
