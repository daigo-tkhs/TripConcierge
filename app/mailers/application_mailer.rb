class ApplicationMailer < ActionMailer::Base
  default from: "TripConcierge <trip.concierge.contact@gmail.com>"
  layout "mailer"

  include Rails.application.routes.url_helpers
end
