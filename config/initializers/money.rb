# Configure Money-Rails
Money.locale_backend = :i18n

MoneyRails.configure do |config|
  config.default_currency = :eur

  # Add custom formatting rules
  config.no_cents_if_whole = false
  config.symbol = "€"
end
