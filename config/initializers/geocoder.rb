# frozen_string_literal: true

Geocoder.configure(
  # Street Address lookup
  lookup: :google,

  # API key:
  api_key: Rails.application.credentials.google_maps[:api_key],

  # Geocoding service request timeout, in seconds (default 3):
  timeout: 5,

  # set default units to kilometers:
  units: :km
)
