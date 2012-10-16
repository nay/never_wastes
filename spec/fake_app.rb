require 'factory_girl'
require 'database_cleaner'

# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:users) {|t| t.string :name; t.boolean :deleted; t.datetime :deleted_at }
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
