require 'nenv'

RSpec.describe Nenv do
  let(:env) { instance_double(Hash) } # Hash is close enough
  before { stub_const('ENV', env) }

  describe 'Nenv() helper method' do
    it 'reads from env' do
      expect(ENV).to receive(:[]).with('GIT_BROWSER').and_return('chrome')
      Nenv('git').browser
    end

    it 'return the value from env' do
      allow(ENV).to receive(:[]).with('GIT_BROWSER').and_return('firefox')
      expect(Nenv('git').browser).to eq('firefox')
    end
  end

  describe 'Nenv() module' do
    it 'reads from env' do
      expect(ENV).to receive(:[]).with('CI').and_return('true')
      Nenv.ci?
    end

    it 'return the value from env' do
      allow(ENV).to receive(:[]).with('CI').and_return('false')
      expect(Nenv.ci?).to be(false)
    end

    context 'with no method' do
      it 'automatically creates the method' do
        expect(ENV).to receive(:[]).with('FOO').and_return('true')
        Nenv.foo?
      end
    end

    context 'with existing method' do
      before do
        Nenv.instance.create_method(:foo?)
      end

      it 'reads from env' do
        expect(ENV).to receive(:[]).with('FOO').and_return('true')
        Nenv.foo?
      end

      it 'return the value from env' do
        expect(ENV).to receive(:[]).with('FOO').and_return('true')
        expect(Nenv.foo?).to be(true)
      end
    end
  end
end
