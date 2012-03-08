# Never Wastes

Never Wastes adds soft delete to ActiveRecord.

It's similar to acts_as_paranoid but simpler. 

## Bundler

    gem 'never_wastes'

## Usage

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

Next step is to specify never_wastes in your model which needs soft delete.

    class YourModel < ActiveRecord::Base
      never_wastes
    end

Then you can use destroy for soft delete.

    model.destroy

If you want hard delete, use destroy!.

    model.destroy!

You can get non-deleted models by default.

    models = YourModel.all # deleted models are not included

If you need to get models with deleted ones, you can use with_deleted.

    models = YourModel.with_deleted.all

In your destroy callbacks, you can use softly_destroying? to check if you are in soft delete or hard delete.

   after_destroy :delete_files
   private
   def delete_files
     return if sortly_destroying?
     # delete files associated with the model object
   end

Use never_wastes? to check if a model supports soft delete or not.

    YourModel.never_wastes?

