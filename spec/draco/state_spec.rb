require "draco"

RSpec.describe Draco::State do
  class StateComponent < Draco::Component
    include Draco::State

    state :state, [:first, :second]
  end

  class DefaultComponent < Draco::Component
    include Draco::State

    state :state, [:first, :second], default: :second
  end

  describe "#state" do
    subject { StateComponent.new }

    it "has an initial value" do
      expect(subject.state).to eq(:first)
    end

    it "sets the default value" do
      component = DefaultComponent.new

      expect(component.state).to eq(:second)
    end

    it "throws an exception when the default is not in the list" do
      expect do
        class IncorrectComponent < Draco::Component
          include Draco::State

          state :state, [:first, :second], default: :third
        end
      end.to raise_exception(Draco::State::InvalidState)
    end
  end

  describe "#next_state" do
    subject { StateComponent.new }

    it "doesn't have an initial value" do
      expect(subject.next_state).to be_nil
    end
  end

  describe "#state=" do
    subject { StateComponent.new }

    it "sets next_state with a valid state" do
      subject.state = :second
      expect(subject.state).to eq(:first)
      expect(subject.next_state).to eq(:second)
    end

    it "throws an error with an invalid state" do
      expect { subject.state = :third }.to raise_exception(Draco::State::InvalidState)
    end
  end

  describe "#next_state=" do
    subject { StateComponent.new }

    it "raises an error" do
      expect { subject.next_state = :second }.to raise_exception(NoMethodError)
    end
  end

  describe "#commit_state" do
    subject { StateComponent.new }

    it "sets the new state" do
      subject.state = :second
      subject.commit_state

      expect(subject.state).to eq(:second)
    end

    it "clears the next state" do
      subject.state = :second
      subject.commit_state

      expect(subject.next_state).to be_nil
    end
  end
end
