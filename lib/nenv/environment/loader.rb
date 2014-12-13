module Nenv
  class Environment
    class Loader
      def initialize(meth)
        @bool = meth.to_s.end_with?('?')
      end

      def load(raw_value, &callback)
        return callback.call(raw_value) if callback
        @bool ? _to_bool(raw_value) : raw_value
      end

      private

      def _to_bool(raw_value)
        case raw_value
        when nil
          nil
        when ''
          fail ArgumentError, "Can't convert empty string into Bool"
        when '0', 'false', 'n', 'no', 'NO', 'FALSE'
          false
        else
          true
        end
      end
    end
  end
end
