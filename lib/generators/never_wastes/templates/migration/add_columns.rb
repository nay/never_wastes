class AddNeverWastesColumnsTo<%= model_class_name.tableize.camelize %> < ActiveRecord::Migration

  def change
    add_column :<%= model_class_name.tableize %>, :deleted, :boolean, :null => false, :default => false

    ## If you need a timestamp
    # add_column :<%= model_class_name.tableize %>, :deleted_at, :datetime

    ## If you need to have unique index for that table, waste_id will help.
    # add_column :<%= model_class_name.tableize %>, :waste_id, :integer, :null => false, :default => 0
    # add_index :<%= model_class_name.tableize %>, [:name, :waste_id], :unique => true
  end
end
