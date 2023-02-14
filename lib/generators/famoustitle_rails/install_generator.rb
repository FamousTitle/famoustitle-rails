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

      def copy_files
        Dir[
          "app/controllers/*", 
          "app/graphql/*", 
          "app/models/*",
          "config/*",
          "config/db/migrate/*",
          "config/initializers/*",
          "lib/tasks/*"
        ].each do |file|
          template(file, file, force: true) if File.exists?(file)
        end
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
      argument :password_reset_token, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true
    end

    def user_reset_password(password_reset_token:, password:, password_confirmation:)
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

      # rails 7+ install foreman with sudo
      def add_sudo_to_foreman
        file = 'bin/dev'
        gsub_file file, "gem install foreman", 'sudo gem install foreman'
      end

      def add_server_binding
        file = 'Procfile.dev'
        gsub_file file, "rails server", 'rails server -b 0.0.0.0'
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
