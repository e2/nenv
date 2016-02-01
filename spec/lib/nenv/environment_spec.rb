require 'yaml'

require 'nenv/environment'

RSpec.describe Nenv::Environment do
  class MockEnv < Hash # a hash is close enough
    def []=(k, v)
      super(k.to_s, v.to_s)
    end
  end

  before { stub_const('ENV', MockEnv.new) }
  subject { instance }

  shared_examples 'accessor methods' do
    describe 'predicate method' do
      before { subject.create_method(:foo?) }

      it 'responds to it' do
        expect(subject).to respond_to(:foo?)
      end

      context 'when the method already exists' do
        let(:error) { described_class::AlreadyExistsError }
        let(:message) { 'Method :foo? already exists' }
        specify do
          expect do
            subject.create_method(:foo?)
          end.to raise_error(error, message)
        end
      end

      context 'with value stored in ENV' do
        before { ENV[sample_key] = value }

        describe 'when value is truthy' do
          let(:value) { 'true' }
          it 'should return true' do
            expect(subject.foo?).to eq true
          end
        end

        describe 'when value is falsey' do
          let(:value) { '0' }
          it 'should return false' do
            expect(subject.foo?).to eq false
          end
        end
      end
    end

    describe 'reader method' do
      context 'when added' do
        before { subject.create_method(:foo) }

        it 'responds to it' do
          expect(subject).to respond_to(:foo)
        end

        context 'when the method already exists' do
          let(:error) { described_class::AlreadyExistsError }
          let(:message) { 'Method :foo already exists' }
          specify do
            expect do
              subject.create_method(:foo)
            end.to raise_error(error, message)
          end
        end
      end

      context 'with value stored in ENV' do
        before { ENV[sample_key] = value }

        context 'with no block' do
          before { instance.create_method(:foo) }
          let(:value) { 123 }

          it 'returns marshalled stored value' do
            expect(subject.foo).to eq '123'
          end
        end

        context 'with block' do
          before { instance.create_method(:foo) { |data| YAML.load(data) } }
          let(:value) { "---\n:foo: 5\n" }

          it 'returns unmarshalled stored value' do
            expect(subject.foo).to eq(foo: 5)
          end
        end
      end
    end

    describe 'writer method' do
      context 'when added' do
        before { subject.create_method(:foo=) }

        it 'responds to it' do
          expect(subject).to respond_to(:foo=)
        end

        context 'when the method already exists' do
          let(:error) { described_class::AlreadyExistsError }
          let(:message) { 'Method :foo= already exists' }
          specify do
            expect do
              subject.create_method(:foo=)
            end.to raise_error(error, message)
          end
        end
      end

      describe 'env variable' do
        after { expect(ENV[sample_key]).to eq result }

        context 'with no block' do
          before { subject.create_method(:foo=) }
          let(:result) { '123' }

          it 'stores a converted to string value' do
            subject.foo = 123
          end
        end

        context 'with block' do
          before { subject.create_method(:foo=) { |data| YAML.dump(data) } }
          let(:result) { "---\n:foo: 5\n" }

          it 'stores a marshaled value' do
            subject.foo = { foo: 5 }
          end
        end
      end
    end
  end

  context 'with no namespace' do
    let(:instance) { described_class.new }
    let(:sample_key) { 'FOO' }
    include_examples 'accessor methods'
  end

  context 'with any namespace' do
    let(:namespace) { 'bar' }
    let(:sample_key) { 'BAR_FOO' }
    let(:instance) { described_class.new(namespace) }
    include_examples 'accessor methods'

    context 'with a method containing underscores' do
      before { instance.create_method(:foo_baz) }

      it 'reads the correct variable' do
        ENV['BAR_FOO_BAZ'] = 123
        expect(subject.foo_baz).to eq '123'
      end
    end
  end
end
