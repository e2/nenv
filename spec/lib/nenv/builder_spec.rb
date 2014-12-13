require 'nenv/builder'

RSpec.describe Nenv::Builder do
  describe '#build' do
    before do
      allow(ENV).to receive(:[]).with('FOO')
    end

    it 'returns a class with the given methods' do
      FooEnv = Nenv::Builder.build do
        create_method(:foo?)
      end
      FooEnv.new.foo?
    end

    context 'with duplicate methods' do
      it 'fails' do
        expect do
          FooEnv = Nenv::Builder.build do
            create_method(:foo?)
            create_method(:foo?)
          end
        end.to raise_error(Nenv::Environment::AlreadyExistsError)
      end
    end
  end
end
