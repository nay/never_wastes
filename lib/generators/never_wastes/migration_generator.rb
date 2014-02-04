require 'rails/generators/migration'

module NeverWastes
  module Generators

    class MigrationGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      argument :model, :require => true, :type => :string, :desc => "Specify the model class name"

      def copy_migration_file
        migration_template "migration/add_columns.rb", "db/migrate/add_never_wastes_columns_to_#{model_class_name.tableize}.rb"
      end

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          sleep 1 # make sure each time we get a different timestamp
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      private

      def model_class_name
        model.classify
      end
    end
  end
end
