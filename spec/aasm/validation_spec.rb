require_relative '../spec_helper'

RSpec.describe AASM::Validation do
  let(:foo_class) do
    Class.new do
      include AASM
      has_aasm_validation
      attr_accessor :state

      def initialize
        @state = :matched
      end

      aasm :state do
        state :matched
        state :booked
        state :quoted
        event :quote do
          transitions from: :matched,
                      to: :quoted,
                      guard: [validate(:may_book?, :book_error, message: 'Failed due to #may_book?')]
        end

        event :book do
          transitions from: :matched,
                      to: :booked,
                      guard: [validate(:may_unbook?, :unbook_error, message: 'Failed due to #may_unbook?')]
        end

        event :unbook do
          transitions from: :booked,
                      to: :matched
        end

        event :success do
          transitions from: :matched,
                      to: :quoted,
                      guard: validate(:always_success, :should_not_see_this_error)
        end

        event :failed_by_proc_validation do
          transitions from: :matched,
                      to: :quoted,
                      guard: validate(proc { always_fail }, :proc_error, message: 'Failed due to proc validator')
        end

        event :fail_with_key_only do
          transitions from: :matched,
                      to: :quoted,
                      guard: validate(:always_fail, :key_only)
        end
      end

      private

      def always_fail
        false
      end

      def always_success
        true
      end
    end
  end

  describe 'validations' do
    let(:foo) { foo_class.new }

    subject { foo.may_quote? }

    context 'when symbols validation failed' do
      it 'should return error messages through #aasm_error_messages' do
        expect(subject).to eq false
        expect(foo.aasm_error_messages).to eq({
                                                book_error: "Failed due to #may_book?",
                                                unbook_error: "Failed due to #may_unbook?"
                                              })
      end
    end

    context 'when proc validation failed' do
      subject { foo.may_failed_by_proc_validation? }
      it 'should return error messages through #aasm_error_messages' do
        expect(subject).to eq false
        expect(foo.aasm_error_messages).to eq({
                                                proc_error: 'Failed due to proc validator'
                                              })
      end
    end

    context 'when validation failure message is not provided' do
      subject { foo.may_fail_with_key_only? }
      it 'should return default error message' do
        expect(subject).to eq false
        expect(foo.aasm_error_messages).to eq({
                                                key_only: "Event [fail_with_key_only] is failed by :key_only"
                                              })
      end
    end

    context 'clear error message' do
      context 'by event name' do
        it 'should remove from messages' do
          expect(subject).to eq false
          foo.clear_aasm_error(:quote)
          expect(foo.aasm_error_messages).to eq({
                                                  unbook_error: "Failed due to #may_unbook?"
                                                })
        end
      end

      context 'when event name is not given' do
        it 'should clear all messages' do
          subject
          foo.clear_aasm_error
          expect(foo.aasm_error_messages).to eq({})
        end
      end
    end

    context 'when there is no validation error' do
      subject { foo.may_success? }
      it 'should return true without any error messages' do
        expect(subject).to eq true
        expect(foo.aasm_error_messages).to eq({})
      end
    end
  end
end
