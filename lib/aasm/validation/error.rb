module AASM
  module Validation
    class Error
      extend ActiveModel::Naming
      attr_reader :name, :errors

      def initialize(args = {})
        @name = args[:name] || :aasm
        @errors = ActiveModel::Errors.new(self)
      end

      def add_error(err_key, message: nil, nspace: false)
        err_key = "#{nspace}__#{err_key}" if nspace
        errors.add(name, err_key, message: message || "Event [#{name}] is failed by :#{err_key}")
      end

      # @return [Hash]
      def error_messages
        return {} unless (keys = error_keys)
        keys.zip(errors.messages[name]).to_h
      end

      def clear
        @errors = ActiveModel::Errors.new(self)
      end

      # @private
      def read_attribute_for_validation(_attr)
        name
      end

      # @private
      def self.human_attribute_name(_attr, _options = {})
        name
      end

      # @private
      def self.lookup_ancestors
        [self]
      end

      private

      # @return [Array<Symbol>]
      def error_keys
        return [] unless (details = errors.details[name])
        details.map {|h| h[:error]}
      end
    end
  end
end