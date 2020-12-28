# Draco::StateMachine

This library provides a DSL to define state machine based systems in [Draco](https://github.com/guitsaru/draco).

## Usage

### Components

This library provides a way to add a state attribute to a component.

```ruby
class GuardBehavior < Draco::Component
  include Draco::State

  state :state, [:patrolling, :alert], default: :patrolling
end

class Guard < Draco::Entity
  component GuardBehavior
end
```

This gives us the ability to say we want the system to set a new state.

```ruby
guard.guard_behavior.state = :alert

guard.guard_behavior.state
# => :patrolling

guard.guard_behavior.next_state
# => :alert
```

### Systems

Now that we have a component, we can implement the state machine as a System.

```ruby
class GuardBehaviorStateMachine < Draco::System
  include Draco::StateMachine

  component GuardBehavior, :state

  on(:alert) do |entity|
    entity.components << Radio.new
  end

  on(:patrolling) do |entity|
    entity.components.delete(Radio)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/draco-state_machine. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/draco-state_machine/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Draco::StateMachine project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/draco-state_machine/blob/master/CODE_OF_CONDUCT.md).
