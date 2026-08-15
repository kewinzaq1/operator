module Tools
  class CalendarTool
    Slot = Struct.new(:starts_at, :ends_at, :reason, keyword_init: true)
    Candidate = Struct.new(:customer, :score, :why, keyword_init: true)

    def initialize(business)
      @business = business
    end

    def open_slots(date = Time.zone.today)
      hours = @business.policy.working_hours_for(date)
      return [] if hours.blank?

      start_time = Time.zone.parse("#{date} #{hours["start"] || hours[0] || "07:00"}")
      end_time = Time.zone.parse("#{date} #{hours["end"] || hours[1] || "21:00"}")
      duration = default_service.duration_minutes.minutes
      booked = @business.appointments.scheduled.or(@business.appointments.completed)
        .where(starts_at: start_time..end_time)

      slots = []
      cursor = start_time
      while cursor + duration <= end_time
        unless booked.any? { |appt| appt.starts_at == cursor }
          slots << Slot.new(starts_at: cursor, ends_at: cursor + duration, reason: "empty")
        end
        cursor += duration
      end

      @business.appointments.unrecovered.where(starts_at: start_time..end_time).each do |cancelled|
        slots << Slot.new(starts_at: cancelled.starts_at, ends_at: cancelled.ends_at, reason: "cancellation") unless slots.any? { |s| s.starts_at == cancelled.starts_at }
      end

      slots.uniq { |s| s.starts_at }.sort_by(&:starts_at)
    end

    def replacement_candidates(appointment, limit: 3)
      hour = appointment.starts_at.strftime("%H:%M")
      weekday = appointment.starts_at.strftime("%A")

      @business.customers.active.map do |customer|
        next if customer.id == appointment.customer_id
        next if conflicting?(customer, appointment)

        history = customer.appointments.where.not(status: "cancelled")
        same_hour = history.select { |a| a.starts_at.strftime("%H:%M") == hour }.count
        same_day = history.select { |a| a.starts_at.strftime("%A") == weekday }.count
        prefers_time = customer.preferred_times_list.include?(hour) || customer.preferred_times_list.include?("evening")
        prefers_day = customer.preferred_days_list.map(&:capitalize).include?(weekday)

        score = (same_hour * 5) + (same_day * 2) + (prefers_time ? 4 : 0) + (prefers_day ? 2 : 0)
        score += 3 if customer.demo_behavior == "accept"
        next if score <= 0

        why = if same_hour.positive?
          "accepted this #{hour} slot #{same_hour} #{same_hour == 1 ? "time" : "times"} before"
        elsif prefers_time
          "usually trains around #{hour}"
        else
          "often books #{weekday}s"
        end

        Candidate.new(customer: customer, score: score, why: why)
      end.compact.sort_by { |c| -c.score }.first(limit)
    end

    def book!(customer:, service:, starts_at:, source_appointment: nil)
      ends_at = starts_at + service.duration_minutes.minutes
      appointment = @business.appointments.create!(
        customer: customer,
        service: service,
        starts_at: starts_at,
        ends_at: ends_at,
        status: "scheduled",
        price: service.price,
        payment_status: "unpaid"
      )
      source_appointment&.update!(recovered_by_appointment: appointment)
      customer.update!(last_visit_at: [ customer.last_visit_at, starts_at ].compact.max, status: "active")
      appointment
    end

    def default_service
      @business.services.order(:id).first
    end

    private

    def conflicting?(customer, appointment)
      customer.appointments.scheduled.where(starts_at: appointment.starts_at).exists?
    end
  end
end
