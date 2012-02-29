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
        alias_method :destroy!, :destroy

        def destroy_softly
          @destroying_softly = true
          ret = with_transaction_returning_status do
            run_callbacks :destroy do
              self.class.where(self.class.primary_key.to_sym => id).update_all(:deleted => true)
              self.deleted = true
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
