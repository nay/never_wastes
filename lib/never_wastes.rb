require 'active_record'
require "never_wastes/version"

module NeverWastes
  module Common
    def self.included(base)
      base.class_eval do
        def self.never_wastes
          include(NeverWastes::SoftDestroy)
        end
        def self.never_wastes?
          include?(NeverWastes::SoftDestroy)
        end
      end
    end

    private
    def destroying_softly?
      false
    end
  end

  module SoftDestroy
    def self.included(base)
      base.class_eval do
        class_attribute :never_wastes_boolean_column_name, :never_wastes_datetime_column_name, :never_wastes_id_column_name
        self.never_wastes_boolean_column_name = :deleted
        self.never_wastes_datetime_column_name = :deleted_at
        self.never_wastes_id_column_name = :waste_id

        alias_method :demolish, :destroy
        alias_method :demolish!, :destroy! if instance_methods.include?(:destroy!)

        def destroy_softly
          @destroying_softly = true
          ret = with_transaction_returning_status do
            run_callbacks :destroy do
              stamps = soft_destroy_stamps
              self.class.where(self.class.primary_key.to_sym => id).update_all(stamps)
              stamps.each {|key, value| send("#{key}=", value)}
              @destroyed = true
              freeze
            end
          end
          @destroying_softly = nil
          ret
        end
        alias_method :destroy, :destroy_softly

        default_scope {where(:deleted => false)}

        class << self
          def with_deleted
            unscoped
          end

          alias_method :demolish_all, :delete_all

          def delete_all_softly
            updates = sanitize_sql_for_assignment(never_wastes_boolean_column_name => true)
            if column_names.include?(never_wastes_datetime_column_name.to_s)
              updates << ","
              updates << sanitize_sql_for_assignment(never_wastes_datetime_column_name => current_time)
            end
            if column_names.include?(never_wastes_id_column_name.to_s)
              updates << ","
              updates << "#{never_wastes_id_column_name.to_s} = #{primary_key}"
            end
            update_all(updates)
          end
          alias_method :delete_all, :delete_all_softly
        end

        private
        def soft_destroy_stamps
          stamps = {self.class.never_wastes_boolean_column_name => true}
          stamps[self.class.never_wastes_datetime_column_name] = self.class.current_time if self.class.column_names.include?(self.class.never_wastes_datetime_column_name.to_s)
          stamps[self.class.never_wastes_id_column_name] = id if self.class.column_names.include?(self.class.never_wastes_id_column_name.to_s)
          stamps
        end

        # useful in callbacks
        def destroying_softly?
          @destroying_softly
        end

        def self.current_time
          default_timezone == :utc ? Time.now.utc : Time.now
        end
      end
    end

  end
end

ActiveRecord::Base.send(:include, NeverWastes::Common)
