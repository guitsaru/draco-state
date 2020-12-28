module Draco
  module State
    class InvalidState < StandardError; end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods
      def state(name, values, opts = {})
        initial = opts.delete(:default) || values.first
        raise InvalidState, "default value of #{initial.inspect} is not in #{values.inspect}" unless values.include?(initial)

        attribute name, default: initial
        attribute "next_#{name}"

        define_method "#{name}=" do |value|
          if values.include?(value)
            instance_variable_set("@next_#{name}", value)
          else
            raise InvalidState.new("#{value.inspect} is not in #{values.inspect}")
          end
        end

        define_method "next_#{name}=" do |value|
          message = "can't set next_#{name}"
          raise NoMethodError, message
        end

        define_method "commit_#{name}" do
          instance_variable_set("@#{name}", instance_variable_get("@next_#{name}"))
          instance_variable_set("@next_#{name}", nil)
        end
      end
    end
  end

  module StateMachine
    VERSION = "0.0.1"

    def self.included(mod)
      mod.extend ClassMethods
      mod.prepend InstanceMethods
    end

    module InstanceMethods
      def tick(context)
        system_component = self.class.instance_variable_get(:@component)
        component_name = Draco.underscore(system_component.first.name.to_s).to_sym
        attribute = system_component.last

        entities.each do |entity|
          component = entity.components[component_name]
          next_value = component.send("next_#{attribute}")
          next unless next_value

          events = self.class.instance_variable_get(:@transition_events)[next_value]

          events.each do |event|
            instance_exec(entity, &event)
          end

          component.send("commit_#{attribute}")
        end

        super
      end
    end

    module ClassMethods
      def self.extended(mod)
        mod.instance_variable_set(:@transition_events, Hash.new { |h, k| h[k] = [] })
      end

      def component(component, attribute)
        @component = [component, attribute]

        filter(component)
      end

      def on(state, &block)
        @transition_events[state] << block
      end
    end
  end
end
