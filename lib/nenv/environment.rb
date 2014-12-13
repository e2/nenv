require 'nenv/environment/dumper'
require 'nenv/environment/loader'

module Nenv
  class Environment
    class Error < ArgumentError
    end

    class MethodError < Error
      def initialize(meth)
        @meth = meth
      end
    end

    class AlreadyExistsError < MethodError
      def message
        format('Method %s already exists', @meth.inspect)
      end
    end

    def initialize(namespace = nil)
      @namespace = (namespace ? namespace.upcase : nil)
    end

    def create_method(meth, &block)
      fail(AlreadyExistsError, meth) if respond_to?(meth)

      (class << self; self; end).send(:define_method, meth) do |*args|
        raw_value = args.first
        env_name = [@namespace, _sanitize(meth)].compact.join('_')

        callback = block
        if args.size == 1
          ENV[env_name] = Dumper.new.dump(raw_value, &callback)
        else
          Loader.new(meth).load(ENV[env_name], &callback)
        end
      end
    end

    private

    def _sanitize(meth)
      meth.to_s[/^([^=?]*)[=?]?$/, 1].upcase
    end
  end
end
