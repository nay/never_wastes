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
        @never_wastes_boolean_column_name = :deleted
        @never_wastes_datetime_column_name = :deleted_at
        def self.soft_destroy_stamps
          stamps = {@never_wastes_boolean_column_name => true}
          stamps[@never_wastes_datetime_column_name] = Time.now if column_names.include?(@never_wastes_datetime_column_name.to_s)
          stamps
        end

        alias_method :destroy!, :destroy

        def destroy_softly
          @destroying_softly = true
          ret = with_transaction_returning_status do
            run_callbacks :destroy do
              stamps = self.class.soft_destroy_stamps
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

        def self.with_deleted
          unscoped
        end

        private
        # useful in callbacks
        def destroying_softly?
          @destroying_softly
        end
      end
    end

  end
end

ActiveRecord::Base.send(:include, NeverWastes::Common)
