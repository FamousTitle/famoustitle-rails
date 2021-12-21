module FamoustitleRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
    
      def remove_setup_gem
        gsub_file 'Gemfile', /gem 'famoustitle_rails'.*/, ""
      end

      def add_gems
        gem 'goldiloader', '~> 4.1.2'
        gem 'graphql', '~> 1.12.12'
        gem 'rack-cors', '~> 1.1.1'
        gem 'lockbox', '~> 0.6.5'
        gem 'blind_index', '~> 2.2.0'
        gem 'fameauth', git: 'https://github.com/vleango/fameauth.git', tag: "1.2.0"
      end
  
      def create_cors_config_file
        template "config/initializers/cors.rb", "config/initializers/cors.rb"
      end
  
      def update_application_for_dns_fix
        application(nil, env: "development") do
          "Rails.application.config.hosts = nil"
        end
      end
  
      def setup_devise
        template "models/user.rb", "models/user.rb"
      end

      def install_gems
        Bundler.with_original_env do
          run "bundle install"
        end
      end
  
      def setup_graphql
        run "rails generate graphql:install"
        #gsub_file 'Gemfile', "gem 'graphiql-rails', group: :development", ''
  
        file = 'app/controllers/graphql_controller.rb'
        gsub_file file, "# protect_from_forgery with: :null_session", 'protect_from_forgery with: :null_session'
        gsub_file file, "# current_user: current_user,", 'current_user: current_user,'
        
        inject_into_file file, before: "def execute" do
          "include ActiveStorage::SetCurrent\n\n"
        end
      end

      def hide_graphql_schema
        file = Dir["#{Rails.root}/app/graphql/*_schema.rb"].first

        inject_into_file file, after: '< GraphQL::Schema' do
          "\n  disable_schema_introspection_entry_point unless Rails.env.development?\n  disable_type_introspection_entry_point unless Rails.env.development?\n"
        end
      end
  
      def copy_starting_point_routes
        template "config/routes.rb", "config/routes.rb", force: true
      end
  
      def setup_database
        file = 'config/database.yml'
        gsub_file file, "password:", 'password: rails'
        gsub_file file, "host: localhost", 'host: <%= ENV.fetch("RAILS_API_HOST") { "db-mysql" } %>'
  
        inject_into_file file, after: 'host: <%= ENV.fetch("RAILS_API_HOST") { "db-mysql" } %>' do
          "\n  port: <%= ENV.fetch(\"RAILS_API_DB_PORT\") { \"db-mysql\" } %>"
        end
      end

      def create_db_rake_file
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

