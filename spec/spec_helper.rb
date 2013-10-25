$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
# Ensure we use 'syck' instead of 'psych' in 1.9.2
# RubyGems >= 1.5.0 uses 'psych' on 1.9.2, but
# Psych does not yet support YAML 1.1 merge keys.
# Merge keys is often used in mongoid.yml
# See: http://redmine.ruby-lang.org/issues/show/4300
if RUBY_VERSION >= '1.9.2'
  require 'yaml'
  YAML::ENGINE.yamler = 'syck'
end
require 'active_record'
require 'never_wastes'
require 'fake_app'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before :all do
#     ActiveRecord::Base.connection.execute 'CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255))' unless ActiveRecord::Base.connection.table_exists? 'users'
    CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'users'
  end
end
