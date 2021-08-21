module AASM
  module Validation
    module Event
      def validate(code, err_key, message: nil)
        # closure on the event name so that we can referenced it later in the validation execuation
        event_name = name

        case code
        when Proc
          proc do |*args|
            record = self
            res = code.parameters.size == 0 ? record.instance_exec(&code) : record.instance_exec(*args, &code)
            record.aasm_validation(event_name).add_error(err_key, message: message) unless res
            res
          end
        when Symbol, String
          proc do |*args|
            record = self
            res = record.__send__(:method, code.to_sym).arity == 0 ? record.__send__(code) : record.__send__(code, *args)
            record.aasm_validation(event_name).add_error(err_key, message: message) unless res
            res
          end
        else
          raise ArgumentError, 'Code must be Symbol, String or Proc'
        end
      end
      alias :aasm_v :validate
    end
  end
end
