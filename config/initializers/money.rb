# Configure Money-Rails
Money.locale_backend = :i18n

# Set explicit rounding mode to avoid deprecation warning
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

MoneyRails.configure do |config|
  config.default_currency = :eur

  # Add custom formatting rules
  config.no_cents_if_whole = false
  config.symbol = "€"
end
