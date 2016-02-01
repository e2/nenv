require 'yaml'

require 'nenv/environment'

RSpec.describe Nenv::Environment do
  let(:env) { instance_double(Hash) } # a hash is close enough
  before(:each) { stub_const('ENV', env) }

  context 'without integration' do
    let(:dumper) { instance_double(described_class::Dumper) }
    let(:loader) { instance_double(described_class::Loader) }

    before do
      allow(described_class::Dumper).to receive(:new).and_return(dumper)
      allow(described_class::Loader).to receive(:new).and_return(loader)
    end

    context 'with no namespace' do
      let(:instance) { described_class.new }

      context 'with an existing method' do
        before do
          subject.create_method(:foo?)
        end

        it 'uses the name as full key' do
          expect(ENV).to receive(:[]).with('FOO').and_return('true')
          expect(loader).to receive(:load).with('true').and_return(true)
          expect(subject.foo?).to eq(true)
        end
      end
    end

    context 'with any namespace' do
      let(:namespace) { 'bar' }
      let(:instance) { described_class.new(namespace) }

      describe 'creating a method' do
        subject { instance }

        before do
          subject.create_method(:foo)
        end

        it { is_expected.to respond_to(:foo) }

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

      describe 'calling' do
        subject { instance }

        context 'when method does not exist' do
          let(:error) { NoMethodError }
          let(:message) { /undefined method `foo' for/ }
          it { expect { subject.foo }.to raise_error(error, message) }
        end

        context 'with a reader method' do
          context 'with no block' do
            before { instance.create_method(meth) }

            context 'with a normal method' do
              let(:meth) { :foo }
              before do
                allow(loader).to receive(:load).with('123').and_return(123)
              end

              it 'returns unmarshalled stored value' do
                expect(ENV).to receive(:[]).with('BAR_FOO').and_return('123')
                expect(subject.foo).to eq 123
              end
            end

            context 'with a bool method' do
              let(:meth) { :foo? }

              it 'references the proper ENV variable' do
                allow(loader).to receive(:load).with('false').and_return(false)
                expect(ENV).to receive(:[]).with('BAR_FOO').and_return('false')
                expect(subject.foo?).to eq false
              end
            end
          end

          context 'with a block' do
            let(:block) { proc { |data| YAML.load(data) } }
            before do
              instance.create_method(:foo, &block)
            end

            let(:value) { "---\n:foo: 5\n" }

            it 'unmarshals using the block' do
              allow(ENV).to receive(:[]).with('BAR_FOO')
                .and_return(value)

              allow(loader).to receive(:load).with(value) do |arg|
                block.call(arg)
              end

              expect(subject.foo).to eq(foo: 5)
            end
          end
        end

        context 'with a writer method' do
          before { instance.create_method(:foo=) }

          it 'set the environment variable' do
            expect(ENV).to receive(:[]=).with('BAR_FOO', '123')
            allow(dumper).to receive(:dump).with(123).and_return('123')
            subject.foo = 123
          end

          it 'marshals and stores the value' do
            expect(ENV).to receive(:[]=).with('BAR_FOO', '123')
            allow(dumper).to receive(:dump).with(123).and_return('123')
            subject.foo = 123
          end
        end

        context 'with a method containing underscores' do
          before { instance.create_method(:foo_baz) }
          it 'reads the correct variable' do
            expect(ENV).to receive(:[]).with('BAR_FOO_BAZ').and_return('123')
            allow(loader).to receive(:load).with('123').and_return(123)
            subject.foo_baz
          end
        end

        context 'with a block' do
          before do
            instance.create_method(:foo=) { |data| YAML.dump(data) }
          end

          let(:result) { "---\n:foo: 5\n" }

          it 'marshals using the block' do
            allow(ENV).to receive(:[]=).with('BAR_FOO', result)

            allow(dumper).to receive(:dump).with(foo: 5) do |arg, &block|
              expect(block).to be
              block.call(arg)
            end

            subject.foo = { foo: 5 }
          end
        end

        context 'with an unsanitized name' do
          pending
        end
      end
    end
  end

  describe 'with integration' do
    context 'with any namespace' do
      let(:namespace) { 'baz' }
      let(:instance) { described_class.new(namespace) }
      subject { instance }

      context 'with a reader method' do
        context 'with no block' do
          before { instance.create_method(:foo) }

          it 'returns the stored value' do
            allow(ENV).to receive(:[]).with('BAZ_FOO').and_return('123')
            expect(subject.foo).to eq '123'
          end
        end

        context 'with a block' do
          before do
            instance.create_method(:foo) { |data| YAML.load(data) }
          end

          it 'unmarshals the value' do
            expect(ENV).to receive(:[]).with('BAZ_FOO')
              .and_return("---\n:foo: 5\n")

            expect(subject.foo).to eq(foo: 5)
          end
        end
      end

      context 'with a writer method' do
        context 'with no block' do
          before { instance.create_method(:foo=) }

          it 'marshals and stores the value' do
            expect(ENV).to receive(:[]=).with('BAZ_FOO', '123')
            subject.foo = 123
          end
        end

        context 'with a block' do
          before do
            instance.create_method(:foo=) { |data| YAML.dump(data) }
          end

          it 'nmarshals the value' do
            expect(ENV).to receive(:[]=).with('BAZ_FOO', "---\n:foo: 5\n")

            subject.foo = { foo: 5 }
          end
        end
      end
    end
  end
end
