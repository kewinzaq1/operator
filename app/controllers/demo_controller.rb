class DemoController < ApplicationController
  def reset
    Demo::Reset.call
    redirect_to dashboard_path, notice: "Demo reset. Calendar, invoices, and leads are back to this morning."
  end
end
