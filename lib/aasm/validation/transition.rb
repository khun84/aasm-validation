module AASM
  module Validation
    module Transition
      # Monkey patch AASM
      def allowed?(obj, *args)
        with_aasm_validation(obj) do
          super
        end
      end

      # @param [Object] obj The object that's calling aasm event
      def with_aasm_validation(obj)
        return yield unless obj.is_a? Instance

        obj.assign_validation(event.name)
        yield
      end
    end
  end
end

