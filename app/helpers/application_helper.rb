module ApplicationHelper
  def money(amount, currency = current_business&.currency || "pln")
    MoneyDisplay.call(amount, currency)
  end

  def owner_first_name
    "Anna"
  end

  def appointment_status_label(appointment)
    case appointment.status
    when "cancelled" then "cancelled"
    when "completed" then "done"
    when "scheduled"
      appointment.starts_at < Time.current ? "in session" : "booked"
    else
      appointment.status
    end
  end
end
