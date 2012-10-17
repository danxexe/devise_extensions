module Devise
  module Models
    # Disableable
    # 
    # TODO: documentation
    #
    module Disableable
      extend ActiveSupport::Concern

      included do
        field :disabled_at, :type => Time

        scope :is_disabled, proc { where(:disabled_at.ne => nil) }
        scope :is_enabled, proc { where(:disabled_at => nil) }
        scope :disabled_state, proc { |state| state ? is_disabled : is_enabled }
        scope :enabled_state, proc { |state| state ? is_enabled : is_disabled }

        define_model_callbacks :disable, :enable
      end

      def disabled?
        disabled_at
      end

      def enabled?
        disabled_at.nil?
      end

      def disable!
        run_callbacks :disable do
          self.disabled_at = Time.now
          save
        end
      end

      def enable!
        run_callbacks :enable do
          self.disabled_at = nil
          save
        end
      end

      def active_for_authentication?
        super && enabled?
      end

    end
  end
end