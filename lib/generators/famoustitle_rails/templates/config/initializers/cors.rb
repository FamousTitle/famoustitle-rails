host = ENV.fetch("RAILS_API_HOST") { "localhost" }

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://#{host}:3000"
    
    resource '*',
      headers: :any,
      methods: :any,
      expose: %w(Authorization)
  end
end
