module AASM
  module Validation
    module Instance
      extend ActiveSupport::Concern

      # @!attribute [rw] aasm_validations
      #   @return [Hash<Symbol, Error>]]
      attr_accessor :aasm_validations, :current_aasm_validation

      def setup_aasm_validation
        @aasm_validations ||= {}.with_indifferent_access
      end

      # @param [Symbol] event_name aasm event name
      def assign_validation(event_name)
        self.aasm_validations ||= {}
        self.aasm_validations[event_name] ||= Error.new(name: event_name)
      end

      # @param [Symbol] event_name Aasm event name
      # @return [Error]
      def aasm_validation(event_name)
        aasm_validations[event_name] || Error.new(name: event_name)
      end

      # @return [Hash]
      def aasm_error_messages
        aasm_validations.each_with_object({}) do |(_, err), memo|
          memo.merge!(err.error_messages)
        end
      end

      def clear_aasm_error(event_name = nil)
        if event_name
          aasm_validations[event_name]&.clear
        else
          aasm_validations.values.each(&:clear)
        end
      end
    end
  end
end