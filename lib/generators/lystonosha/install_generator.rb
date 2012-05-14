require 'rails/generators/migration'

module Lystonosha
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("../../templates", __FILE__)

      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      desc "Creates a Lystonosha initializer."
      def copy_initializer
        template "lystonosha.rb", "config/initializers/lystonosha.rb"
      end

      desc "Creates a migration for Lystonosha models."
      def copy_lystonosha_migration
        migration_template "migration.rb", "db/migrate/create_lystonosha"
      end
    end
  end
end
