# Aasm::Validation

The motivation of building this gem is to make the aasm event query method more friendly to the developer. When `record.may_aasm_event?` failed and you have plenty of guards for that event, you might want to know which guard is not fulfilled instead just the `true/false` returned by the query method.

This gem allows you to configure validation error messages when you add guard to the state machine event. The error messages then can be retrieved via calling `#aasm_error_messages`. See usage section for more examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aasm-validation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aasm-validation

## Usage

To setup validation for your guards, you'll need to use `validate` with your error detail as argument during guard setup.

A default error message will be returned if the `message` keyword argument is `nil`, empty string or not given.

You can clear the aasm error messages if you want to by using `clear_aasm_error`. It will clear all messages regardless of which event causes those messages.

Consider the following aasm initial setup

```ruby
class Job
  include AASM
  # Call this method to opt in for aasm validation
  has_aasm_validation
  
  aasm :state do
    state :phase_1, initial: true
    state :phase_2
    state :phase_3
  end
  
  def always_fail
    false
  end
  
  def always_success
    true
  end
end
```

### Validation with method as symbol

```ruby
# in Job
    
event :symbol_validation do
  transitions from: :phase_1,
              to: :phase_2,
              guards: validate(:always_fail, :phase_1_failure, message: 'Failure from phase 1')
end


job = Job.new
job.may_symbol_validation?
# => false
 
job.aasm_error_messages
# => {phase_1_failure: 'Failure from phase 1'}

job.clear_aasm_message
job.aasm_error_messages
# => {}
```

### Validation with Proc

```ruby
# in Job
    
event :proc_validation do
  transitions from: :phase_1,
              to: :phase_2,
              guards: validate(proc { always_fail }, :phase_1_failure, message: 'Failure from phase 1')
end


job = Job.new
job.may_proc_validation?
# => false
 
job.aasm_error_messages
# => {phase_1_failure: 'Failure from phase 1'}
```

### Multiple events validation

```ruby
# in Job
    
event :first_event do
  transitions from: :phase_1,
              to: :phase_2,
              guards: validate(:may_second_event?, :phase_1_failure, message: 'Failure from phase 1')
end

event :second_event do
  transitions from: :phase_1,
              to: :phase_2,
              guards: validate(:always_fail, :phase_2_failure, message: 'Failure from phase 2')
end

job = Job.new
job.may_first_event?
job.aasm_error_messages

# => {:phase_1_failure => 'Failure from phase 1', :phase_2_failure => 'Failure from phase 2'}
```

### Validation with method that accepts event arguments

Event arguments are passed to the validator just like how AASM passes to the guards.

```ruby
# in Job

event :event_with_args do
  transitions from: :phase_1,
              to: :phase_2,
              guards: validate(:check_args_and_pass, :phase_1_failure, message: 'Failure from phase 1')
end

def check_args_and_pass(args = {})
  puts "print args"
  puts args
  true
end

job = Job.new
job.may_event_with_args?(foo: 'bar')
# => "print args"
# => {:foo => 'bar'}
# => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khun84/aasm-validation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
