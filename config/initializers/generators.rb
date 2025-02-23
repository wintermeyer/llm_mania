Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
  g.test_framework :test_unit,
                   fixture: false,
                   fixture_replacement: :factory_bot,
                   factory_bot: true
end
