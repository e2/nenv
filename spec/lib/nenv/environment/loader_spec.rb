require 'yaml'
require 'nenv/environment/loader'

RSpec.describe Nenv::Environment::Loader do
  context 'with no block' do
    subject { described_class.new(meth).load(value) }

    context 'with a normal method' do
      let(:meth) { :foo }

      context "with \"abc\"" do
        let(:value) { 'abc' }
        it { is_expected.to eq('abc') }
      end
    end

    context 'with a bool method' do
      let(:meth) { :foo? }

      %w(1 true y yes TRUE YES foobar).each do |data|
        context "with #{data.inspect}" do
          let(:value) { data }
          it { is_expected.to eq(true) }
        end
      end

      %w(0 false n no FALSE NO).each do |data|
        context "with #{data.inspect}" do
          let(:value) { data }
          it { is_expected.to eq(false) }
        end
      end

      context 'with nil' do
        let(:value) { nil }
        it { is_expected.to eq(nil) }
      end

      context 'when empty string' do
        let(:value) { '' }
        it do
          expect { subject }.to raise_error(
            ArgumentError, /Can't convert empty string into Bool/
          )
        end
      end
    end
  end

  context 'with a block' do
    subject do
      described_class.new(:foo).load(value) { |data| YAML.load(data) }
    end
    context 'with a yaml string' do
      let(:value) { "--- foo\n...\n" }
      it { is_expected.to eq('foo') }
    end
  end
end
