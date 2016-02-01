require 'yaml'

require 'nenv/environment/dumper'

RSpec.describe Nenv::Environment::Dumper do
  subject { described_class.new.dump(value) }

  context "with \"abc\"" do
    let(:value) { 'abc' }
    it { is_expected.to eq('abc') }
  end

  context 'with 123' do
    let(:value) { 123 }
    it { is_expected.to eq('123') }
  end

  context 'with nil' do
    let(:value) { nil }
    it { is_expected.to eq(nil) }
  end

  context 'with a block' do
    subject do
      described_class.new { |data| YAML.dump(data) }.dump(value)
    end

    context 'with a yaml string' do
      let(:value) { { foo: 3 } }
      let(:yaml) { "---\n:foo: 3\n" }
      it { is_expected.to eq(yaml) }
    end
  end
end
