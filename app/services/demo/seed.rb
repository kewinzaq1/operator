module Demo
  class Seed
    def self.call
      new.call
    end

    def call
      Time.use_zone("Europe/Warsaw") { plant }
    end

    private

    def plant
      business = Business.create!(
        name: "Anna Fitness",
        business_type: "personal_trainer",
        currency: "pln",
        timezone: "Europe/Warsaw",
        phone: "+48570100100",
        email: "anna@annafitness.waw.pl"
      )

      hours = %w[monday tuesday wednesday thursday friday saturday].index_with { { "start" => "07:00", "end" => "21:00" } }
      hours["sunday"] = {}
      business.create_policy!(
        session_price: 80,
        currency: "pln",
        working_hours: hours,
        cancellation_window_hours: 24,
        cancellation_fee_percent: 50,
        late_payment_days: 3,
        max_auto_refund: 100,
        max_agent_spend: 50,
        max_human_task_cost: 20,
        communication_tone: "friendly",
        auto_booking_enabled: true,
        auto_payment_enabled: true,
        confidence_threshold: 70
      )

      session = business.services.create!(name: "Personal training", duration_minutes: 60, price: 80, description: "60-minute 1:1 session")
      business.digital_products.create!(name: "4-week home program", kind: "program", price: 120, provider: "whop", description: "Follow-along strength plan")

      now = Time.zone.now
      today = now.beginning_of_day

      marta = cust(business, "Marta Kowalska", "+48570111222", "active", %w[Tuesday Thursday], %w[17:00 evening], 7, "accept", last_visit: 4.days.ago)
      magda = cust(business, "Magda Król", "+48570111223", "active", %w[Monday Wednesday], %w[17:00], 7, "ignore", last_visit: 3.days.ago)
      ewa = cust(business, "Ewa Zielińska", "+48570111224", "active", %w[Tuesday], %w[17:00 18:00], 8, "none", last_visit: 5.days.ago)
      piotr = cust(business, "Piotr Nowak", "+48570111225", "active", %w[Monday], %w[08:00], 7, "pay", last_visit: 8.days.ago)
      tomasz = cust(business, "Tomasz Wiśniewski", "+48570111226", "active", %w[Wednesday], %w[10:00], 7, "none", last_visit: 2.days.ago)
      jakub = cust(business, "Jakub Dąbrowski", "+48570111227", "active", %w[Friday], %w[19:00], 7, "none", last_visit: 6.days.ago, package: true)
      natalia = cust(business, "Natalia Woźniak", "+48570111228", "active", %w[Thursday], %w[09:00], 7, "none", last_visit: 5.days.ago, package: true)
      ola = cust(business, "Ola Kamińska", "+48570111229", "active", %w[Saturday], %w[11:00], 7, "none", last_visit: 1.day.ago)
      wojtek = cust(business, "Wojtek Pawlak", "+48570111230", "active", %w[Monday], %w[19:00], 7, "escalate", last_visit: 2.days.ago, notes: "Twisted knee on a run last weekend.", question: "Should we modify Wojtek's training program after his knee injury?")
      filip = cust(business, "Filip Mazur", "+48570111231", "active", %w[Saturday], %w[17:00], 7, "none", last_visit: 7.days.ago)
      michal = cust(business, "Michał Szymański", "+48570111232", "active", %w[Friday], %w[08:00], 7, "none", last_visit: 1.day.ago)
      ania = cust(business, "Ania Lis", "+48570111233", "active", %w[Wednesday], %w[18:00], 7, "none", last_visit: 3.days.ago)

      kasia = cust(business, "Kasia Lewandowska", "+48570111234", "inactive", %w[Monday], %w[18:00], 7, "none", last_visit: 13.days.ago)
      cust(business, "Adam Wójcik", "+48570111235", "inactive", %w[Thursday], %w[20:00], 10, "none", last_visit: 24.days.ago)
      cust(business, "Lena Grabowska", "+48570111236", "inactive", %w[Tuesday], %w[09:00], 7, "none", last_visit: 21.days.ago)
      cust(business, "Paweł Sikora", "+48570111237", "inactive", %w[Sunday], %w[10:00], 14, "none", last_visit: 30.days.ago)

      bartek = cust(business, "Bartek Jankowski", "+48570111238", "lead", %w[Saturday], %w[10:00], nil, "none")
      zofia = cust(business, "Zofia Maj", "+48570111239", "lead", %w[Monday], %w[17:00], nil, "none")

      business.leads.create!(customer: bartek, source: "instagram", status: "unanswered", last_message_at: 2.days.ago, intent: "price + Saturday", body: "Ile kosztuje trening i czy jest coś w sobotę rano?")
      business.leads.create!(customer: zofia, source: "website", status: "unanswered", last_message_at: 1.day.ago, intent: "trial session", body: "Can I try a session before buying a package?")

      book(business, session, marta, 14.days.ago.change(hour: 17), "completed", "paid")
      book(business, session, marta, 7.days.ago.change(hour: 17), "completed", "paid")
      book(business, session, magda, 17.days.ago.change(hour: 17), "completed", "paid")
      book(business, session, magda, 10.days.ago.change(hour: 17), "completed", "paid")
      book(business, session, ewa, 28.days.ago.change(hour: 17), "completed", "paid")
      book(business, session, ewa, 21.days.ago.change(hour: 17), "completed", "paid")
      book(business, session, kasia, 13.days.ago.change(hour: 18), "completed", "paid")
      book(business, session, kasia, 20.days.ago.change(hour: 18), "completed", "paid")
      book(business, session, kasia, 27.days.ago.change(hour: 18), "completed", "paid")
      book(business, session, piotr, 8.days.ago.change(hour: 8), "completed", "unpaid")
      book(business, session, jakub, 6.days.ago.change(hour: 19), "completed", "paid")
      book(business, session, natalia, 5.days.ago.change(hour: 9), "completed", "paid")
      book(business, session, ola, 1.day.ago.change(hour: 11), "completed", "paid")
      book(business, session, tomasz, 2.days.ago.change(hour: 10), "completed", "paid")
      book(business, session, wojtek, 2.days.ago.change(hour: 19), "completed", "paid")
      book(business, session, michal, 1.day.ago.change(hour: 8), "completed", "paid")
      book(business, session, ania, 3.days.ago.change(hour: 18), "completed", "paid")

      book(business, session, tomasz, today.change(hour: 10), now.hour >= 11 ? "completed" : "scheduled", "paid")
      book(business, session, ola, today.change(hour: 11), now.hour >= 12 ? "completed" : "scheduled", "paid")
      cancelled = book(business, session, filip, today.change(hour: 17), "cancelled", "unpaid")
      cancelled.update!(cancelled_at: now.change(hour: 14, min: 1), cancellation_reason: "something came up at work")

      piotr_appt = business.appointments.find_by(customer: piotr)
      business.payments.create!(
        customer: piotr,
        appointment: piotr_appt,
        provider: "stripe",
        amount: 70,
        currency: "pln",
        status: "overdue",
        due_at: 5.days.ago,
        external_id: nil
      )

      conversation = business.conversations.create!(customer: wojtek, channel: "imessage", status: "open")
      conversation.messages.create!(direction: "inbound", body: "Hey Anna — I twisted my knee on a run. Should we change the program?", provider: "demo", status: "received", sent_at: 3.hours.ago, intent: "UNKNOWN")

      business.business_metrics.create!(metric_type: "revenue", value: 640, occurred_at: 2.days.ago, metadata: { window: "week" })
      business.business_metrics.create!(metric_type: "admin_minutes_avoided", value: 0, occurred_at: today, metadata: {})

      business
    end

    def cust(business, name, phone, status, days, times, interval, behavior, last_visit: nil, package: false, notes: nil, question: nil)
      business.customers.create!(
        name: name,
        email: "#{name.split.first.downcase}@client.annafitness.waw.pl",
        phone: phone,
        status: status,
        preferred_days: days,
        preferred_times: times,
        usual_interval_days: interval,
        demo_behavior: behavior,
        last_visit_at: last_visit,
        last_contacted_at: last_visit,
        package_completed: package,
        notes: notes,
        open_question: question
      )
    end

    def book(business, service, customer, starts_at, status, payment_status)
      business.appointments.create!(
        customer: customer,
        service: service,
        starts_at: starts_at,
        ends_at: starts_at + service.duration_minutes.minutes,
        status: status,
        price: service.price,
        payment_status: payment_status,
        cancelled_at: status == "cancelled" ? starts_at - 3.hours : nil
      )
    end
  end
end
