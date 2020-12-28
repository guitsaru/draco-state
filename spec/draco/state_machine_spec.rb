require "draco"

RSpec.describe Draco::StateMachine do
  class TestComponent < Draco::Component
    include Draco::State

    state :state, [:first, :second]
  end

  class TestEntity < Draco::Entity
    component TestComponent
  end

  class UpdateState < Draco::System
    include Draco::StateMachine

    component TestComponent, :state

    on(:second) do |entity|
      world.test_value = true
    end
  end

  class TestWorld < Draco::World
    attr_accessor :test_value

    entity TestEntity

    systems UpdateState
  end

  it "has a version number" do
    expect(Draco::StateMachine::VERSION).not_to be nil
  end

  describe "#tick" do
    subject { TestWorld.new }

    it "commits the state" do
      entity = subject.entities[TestComponent].first
      entity.test_component.state = :second

      subject.tick(nil)

      expect(entity.test_component.state).to eq(:second)
      expect(entity.test_component.next_state).to be_nil
    end

    it "runs the event" do
      entity = subject.entities[TestComponent].first
      entity.test_component.state = :second

      subject.tick(nil)

      expect(subject.test_value).to be_truthy
    end
  end
end
