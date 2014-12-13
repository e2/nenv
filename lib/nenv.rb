require "nenv/version"

require "nenv/autoenvironment"

def Nenv(namespace=nil)
  Nenv::AutoEnvironment.new(namespace)
end

module Nenv
  class << self
    def respond_to?(meth)
      instance.respond_to?(meth)
    end

    def method_missing(meth, *args)
      instance.send(meth, *args)
    end

    def reset
      @instance = nil
    end

    def instance
      @instance ||= Nenv::AutoEnvironment.new
    end
  end
end
