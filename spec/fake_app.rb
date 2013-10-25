require 'factory_girl'
require 'database_cleaner'

# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.boolean :deleted, :null => false, :default => false
      t.datetime :deleted_at
      t.integer :waste_id, :null => false, :default => 0
    end
    add_index :users, [:name, :waste_id], :unique => true
  end
end

# models
class User < ActiveRecord::Base
  never_wastes
  validates_uniqueness_of :name, :scope => [:name, :deleted]
end

# factory
FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "test %03d" %n }
    deleted false
    deleted_at "2012-03-12 17:37:19"
  end
end
