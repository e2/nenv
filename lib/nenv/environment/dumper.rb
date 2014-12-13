module Nenv
  class Environment
    class Dumper
      def dump(raw_value, &callback)
        return callback.call(raw_value) if callback
        raw_value.nil? ? nil : raw_value.to_s
      end
    end
  end
end
