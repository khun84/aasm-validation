require 'aasm'
require 'active_model'
require 'aasm/validation/version'
require 'aasm/validation/event'
require 'aasm/validation/transition'
require 'aasm/validation/error'
require 'aasm/validation/instance'

module AASM
  module ClassMethods
    def has_aasm_validation
      include Validation::Instance
    end
  end
end

AASM::Core::Event.include AASM::Validation::Event
AASM::Core::Transition.prepend AASM::Validation::Transition
