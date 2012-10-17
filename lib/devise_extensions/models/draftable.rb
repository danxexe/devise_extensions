module Devise
  module Models
    # Draftable
    # 
    # TODO: documentation
    #
    module Draftable
      extend ActiveSupport::Concern

      included do
        field :is_draft, :type => Boolean

        scope :is_draft, where(:is_draft => true)
        scope :is_not_draft, where(:is_draft.ne => true)
        scope :draft_state, proc { |state| state ? is_draft : is_not_draft }

        define_model_callbacks :start_draft, :finish_draft
      end

      def draft?
        is_draft
      end

      def not_draft?
        !is_draft
      end

      def start_draft!
        run_callbacks :start_draft do
          self.is_draft = true
          save
        end
      end

      def finish_draft!
        run_callbacks :finish_draft do
          self.is_draft = false
          save
        end
      end

      def active_for_authentication?
        super && not_draft?
      end

    end
  end
end