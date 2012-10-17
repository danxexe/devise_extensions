module Devise
  module Models
    # Approvable
    # 
    # TODO: documentation
    #
    module Approvable
      extend ActiveSupport::Concern

      included do
        field :approval_status, :type => String
        field :approval_at, :type => Time

        belongs_to :approval_by, :class_name => approver_class

        scope :is_pending_approval, where(:approval_status => nil)
        scope :is_not_pending_approval, where(:approval_status.ne => nil)
        scope :is_approved, where(:approval_status => 'approved')
        scope :is_not_approved, where(:approval_status.ne => 'approved')
        scope :is_rejected, where(:approval_status => 'rejected')
        scope :is_not_rejected, where(:approval_status.ne => 'rejected')

        scope :rejected_state, proc { |state| state ? is_rejected : is_not_rejected }
        scope :pending_approval_state, proc { |state| state ? is_pending_approval : is_not_pending_approval }
        scope :approved_state, proc { |state| state ? is_approved : is_not_approved }

        define_model_callbacks :approval
      end

      def approve!(options = {})
        status = nil

        approval_proc = proc {
          self.approval_status = 'approved'
          self.approval_at = Time.now.utc
          self.approval_by = options[:by]

          generate_reset_password_token

          status = self.save
        }

        if options[:skip_callbacks]
          approval_proc.call
        else
          run_callbacks :approval, &approval_proc
        end

        status
      end

      def reject!(options = {})
        self.approval_status = 'rejected'
        self.approval_at = Time.now.utc
        self.approval_by = options[:by]

        self.save
      end

      def revoke!
        self.approval_status = nil
        self.approval_at = nil
        self.approval_by = nil

        self.save
      end

      def pending_approval?
        approval_status.nil?
      end

      def approved?
        approval_status == 'approved'
      end

      def rejected?
        approval_status == 'rejected'
      end

      def active_for_authentication?
        super && approved?
      end

      module ClassMethods
        Devise::Models.config(self, :approver_class)
      end

    end
  end
end