Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins *ENV.fetch('CORS_ORIGINS').split(" ").map(&:strip)
    origins '*'

    resource '*',
      headers: :any,
      methods: :any,
      expose: %w(Authorization)
  end
end
