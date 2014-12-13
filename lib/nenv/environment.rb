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

    def self.create_method(meth, &block)
      _create_env_method(self, meth, &block)
    end

    def create_method(meth, &block)
      self.class._create_env_method(class << self; self; end, meth, &block)
    end

    private

    def _sanitize(meth)
      meth.to_s[/^([^=?]*)[=?]?$/, 1].upcase
    end

    def self._create_env_method(instance, meth, &block)
      _fail_if_exists(instance, meth)

      instance.send(:define_method, meth) do |*args|
        env_name = [@namespace, _sanitize(meth)].compact.join('_')

        if args.size == 1
          raw_value = args.first
          ENV[env_name] = Dumper.new.dump(raw_value, &block)
        else
          Loader.new(meth).load(ENV[env_name], &block)
        end
      end
    end

    def self._fail_if_exists(instance, meth)
      fail(AlreadyExistsError, meth) if instance.instance_methods.include?(meth)
    end
  end
end
