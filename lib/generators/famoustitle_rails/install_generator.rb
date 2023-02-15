module FamoustitleRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
    
      def remove_setup_gem
        gsub_file 'Gemfile', /gem 'famoustitle_rails'.*/, ""
      end

      def add_gems
        gem 'goldiloader', '~> 4.2.0'
        gem 'graphql', '~> 2.0.14'
        gem 'rack-cors', '~> 1.1.1'
        gem 'devise-jwt', '~> 0.10.0'
        gem 'sendgrid-ruby', '~> 6.6.2'
      end
  
      def update_application_for_dns_fix
        application(nil, env: "development") do
          "Rails.application.config.hosts = nil"
        end
      end

      def install_gems
        Bundler.with_original_env do
          run "bundle install"
        end
      end

      # rails 7+ install foreman with sudo
      def add_sudo_to_foreman
        file = 'bin/dev'
        gsub_file file, "gem install foreman", 'sudo gem install foreman'
      end

      def add_server_binding
        file = 'Procfile.dev'
        gsub_file file, "rails server", 'rails server -b 0.0.0.0'
      end

      def setup_devise
        run "rails generate devise:install"
        run "rails generate devise User"
        run "rails g model allowlisted_jwt user:references jti:string:uniq aud:string exp:datetime"

        file = 'config/initializers/devise.rb'
        inject_into_file file, after: '# config.sign_in_after_change_password = true' do
          <<-HEREDOC

        
  # ==> JWT
  config.jwt do |jwt|
    jwt.secret = ENV['DEVISE_SECRET_KEY']
    jwt.dispatch_requests = [
        ['POST', %r{^/users/sign_in$}], # adding authorization bearer to sign_in header response
        ['POST', %r{^/users$}]          # adding authorization bearer to registration header response
    ]

    jwt.revocation_requests = [
        ['DELETE', %r{^/users/sign_out$}]
    ]

    jwt.request_formats = { user: [:json] }

    jwt.expiration_time = 1.week.to_i
  end
          HEREDOC
        end
      end

      def add_validation_to_allowlisted_jwts
        file = Dir["#{Rails.root}/db/migrate/*_create_allowlisted_jwts.rb"].first
        gsub_file file, "t.string :jti", "t.string :jti, null: false"
        gsub_file file, "t.datetime :exp", "t.datetime :exp, null: false"
      end

      def setup_graphql
        run "rails generate graphql:install"
  
        file = 'app/controllers/graphql_controller.rb'
        gsub_file file, "# protect_from_forgery with: :null_session", 'protect_from_forgery with: :null_session'
        gsub_file file, "# current_user: current_user,", 'current_user: current_user,'
        
        inject_into_file file, before: "def execute" do
          <<-HEREDOC
include ActiveStorage::SetCurrent

          HEREDOC
        end
      end

      def graphql_install_cleanup
        gsub_file 'Gemfile', /gem "graphiql-rails".*/, ""
        template "config/routes.rb", "config/routes.rb", force: true
      end

      def add_graphql_mutations
        file = 'app/graphql/types/mutation_type.rb'
        inject_into_file file, after: "MutationType < Types::BaseObject" do
          <<-HEREDOC

    field :send_password_reset_token, String, null: false do
      argument :email, String, required: true
    end

    def send_password_reset_token(email:)
      user = User.find_by(email: email)
      user.send_password_reset_email if user.present?
      "ok"
    end

    field :user_reset_password, String, null: false do
      argument :reset_password_token, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true
    end

    def user_reset_password(reset_password_token:, password:, password_confirmation:)
      User.reset_password_by_token(
        reset_password_token: reset_password_token,
        password: password,
        password_confirmation: password_confirmation
      )
      "ok"
    end

          HEREDOC
        end
      end

      def hide_graphql_schema
        file = Dir["#{Rails.root}/app/graphql/*_schema.rb"].first

        inject_into_file file, after: '< GraphQL::Schema' do
          <<-HEREDOC
          
  disable_schema_introspection_entry_point unless Rails.env.development?
  disable_type_introspection_entry_point unless Rails.env.development?
          HEREDOC
        end
      end

      def copy_files
        template "app/controllers/registrations_controller.rb", "app/controllers/registrations_controller.rb"
        template "app/controllers/sessions_controller.rb", "app/controllers/sessions_controller.rb"
        template "app/models/user.rb", "app/models/user.rb", force: true
        template "config/initializers/cors.rb", "config/initializers/cors.rb"
        copy_file "config/database.yml", "config/database.yml", force: true
        template "lib/tasks/db.rake", "lib/tasks/db.rake"
      end

      def install_gems_again
        Bundler.with_original_env do
          run "bundle install"
        end
      end
  
      def get_migrations
        run "rails railties:install:migrations"
      end
      
    end
  end
end
