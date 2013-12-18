# Never Wastes

Never Wastes adds soft delete to ActiveRecord.

It's similar to acts_as_paranoid but simpler. 

## Bundler

    gem 'never_wastes'

## Usage

### Migrations

First, add deleted column in your models.

    class AddDeletedToYourModels < ActiveRecord::Migration
      def change
        add_column :your_models, :deleted, :boolean, :null => false, :default => false
      end
    end

Currently the boolean "deleted" column is required.

If you need a timestamp, you can also add deleted_at column.

    class AddDeletedToYourModels < ActiveRecord::Migration
      def change
        add_column :your_models, :deleted, :boolean, :null => false, :default => false
        add_column :your_models, :deleted_at, :datetime
      end
    end

If you need to have unique index for that table, waste_id will help.

    class AddDeletedToYourModels < ActiveRecord::Migration
      def change
        add_column :your_models, :deleted, :boolean, :null => false, :default => false
        add_column :your_models, :deleted_at, :datetime
        add_column :your_models, :waste_id, :integer, :null => false, :default => 0
      end
    end

The waste_id supposed to be 0 when it's not deleted.
When the record is softly deleted, its primary key is copied to waste_id to be unique in all deleted records.
This helps you add unique index for some typical column like 'name' as the following example;

    class AddNameIndexToYourModels < ActiveRecord::Migration
      def up
        add_index :your_models, [:name, :waste_id], :unique => true
      end

      # down is needed
    end

### Declaration

Next step is to specify never_wastes in your model which needs soft delete.

    class YourModel < ActiveRecord::Base
      never_wastes
    end

### Use APIs

Then you can use destroy for soft delete.

    model.destroy

If you want hard delete, use demolish.

    model.demolish

Using Rails 4.0 or later, you can use #demolish! instead of #destroy!.

You can get non-deleted models by default.

    models = YourModel.all # deleted models are not included

This gem also changes .delete_all to soft deletion. You can use .demolish_all as the original .delete_all.

If you need to get models with deleted ones, you can use with_deleted.

    models = YourModel.with_deleted.all

In your destroy callbacks, you can use destroying_softly? to check if you are in soft delete or hard delete.

    after_destroy :delete_files
    private
    def delete_files
      return if destroying_softly?
      # delete files associated with the model object
    end

Use never_wastes? to check if a model supports soft delete or not.

    YourModel.never_wastes?

