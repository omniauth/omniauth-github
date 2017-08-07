module OmniAuth
  RSpec.describe GitHub do
    it 'contains the correct version number' do
      expect(described_class::VERSION).to eq('1.3.1')
    end
  end
end
