module Nenv
  class Environment
    class Dumper
      def initialize(&callback)
        @callback = callback
      end

      def dump(raw_value)
        return @callback.call(raw_value) if @callback
        raw_value.nil? ? nil : raw_value.to_s
      end
    end
  end
end
