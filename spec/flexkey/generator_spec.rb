require 'spec_helper'

describe Flexkey::Generator do
  describe '#new' do
    describe 'validations' do
      it 'raises an exception when format is missing' do
        expect {
          Flexkey::Generator.new(char_pool: { 'n' => :numeric })
        }.to raise_error(Flexkey::GeneratorError, 'format is required')
      end

      it 'raises an exception when format is blank' do
        expect {
          Flexkey::Generator.new(format: '', char_pool: { 'n' => :numeric })
        }.to raise_error(Flexkey::GeneratorError, 'format is required')
      end

      it 'raises an exception when char_pool is missing' do
        expect {
          Flexkey::Generator.new(format: 'nnn')
        }.to raise_error(Flexkey::GeneratorError, 'char_pool is required')
      end

      it 'raises an exception when char_pool has non-string letters' do
        expect {
          Flexkey::Generator.new(format: 'nnn', char_pool: { 123 => :numeric })
        }.to raise_error(Flexkey::GeneratorError,
          'char_pool letters must each be strings of length 1')
      end

      it 'raises an exception when char_pool has letters longer than 1 character' do
        expect {
          Flexkey::Generator.new(format: 'nnn', char_pool: { 'nn' => :numeric })
        }.to raise_error(Flexkey::GeneratorError,
          'char_pool letters must each be strings of length 1')
      end

      it 'raises an exception when char_pool has blank letters' do
        expect {
          Flexkey::Generator.new(format: 'nnn', char_pool: { '' => :numeric })
        }.to raise_error(Flexkey::GeneratorError,
          'char_pool letters must each be strings of length 1')
      end

      it 'raises an exception when no char_pool letters found in format' do
        expect {
          Flexkey::Generator.new(format: 'nnn', char_pool: { 'a' => :numeric })
        }.to raise_error(Flexkey::GeneratorError, 'No char_pool letters present in format')
      end
    end

    context 'when a valid format and char_pool is provided' do
      subject { Flexkey::Generator.new(format: 'nnn', char_pool: { 'n' => :numeric }) }

      its(:format) { is_expected.to eq('nnn') }
      its(:char_pool) { is_expected.to eq({ 'n' => :numeric }) }
      its(:n_possible_keys) { is_expected.to eq(10**3) }
    end
  end

  describe 'accessors' do
    let(:key_gen) {
      Flexkey::Generator.new(format: 'nnn-aaa', char_pool: {
        'n' => :numeric, 'a' => :alpha_upper }) }

    it 'updates the format' do
      key_gen.format = 'aaa-nnn'
      expect(key_gen.format).to eq('aaa-nnn')
    end

    it 'updates the char_pool' do
      key_gen.char_pool = { 'n' => :numeric, 'a' => :alpha_lower }
      expect(key_gen.char_pool).to eq({ 'n' => :numeric, 'a' => :alpha_lower })
    end

    it 'updates the number of possible keys' do
      key_gen.format = 'aaaa-nnnn-0000'
      key_gen.char_pool = { 'n' => :numeric, 'a' => :alpha_lower_clear }
      expect(key_gen.n_possible_keys).to eq(10**4 * 22**4)
    end
  end

  describe '#generate' do
    context 'when a single key is requested' do
      context 'with alphabetical and numeric character types' do
        subject { Flexkey::Generator.new(format: 'aaaaa-nnnn', char_pool: {
          'a' => :alpha_lower, 'n' => :numeric }).generate }

        it { is_expected.not_to be_nil }
        it { is_expected.to match(/^[a-z]{5}-\d{4}$/) }
      end

      context 'with all character types' do
        subject { Flexkey::Generator.new(format: 'u-l-n-v-m-o-s-b', char_pool: {
          'u' => :alpha_upper, 'l' => :alpha_lower, 'n' => :numeric, 'v' => :alpha_upper_clear,
          'm' => :alpha_lower_clear, 'o' => :numeric_clear, 's' => :symbol, 'b' => :basic_symbol
          }).generate }

        it { is_expected.to match(%r{
          ^[A-Z]-[a-z]-[0-9]-[ABCDEFGHJKLMNPQRTUVWXYZ]-[abcdefghjkmnpqrtuvwxyz]-
          [2346789]-[!@#\$%\^&*;:\(\)_\+-=\[\]{}\\\|'",.<>\/?]-[!@#\$%\^&\*;\:]$
          }x) }
      end
    end

    context 'when the format and char_pool change' do
      let(:key_gen) { Flexkey::Generator.new(format: 'aaa-nnn', char_pool: {
        'n' => :numeric, 'a' => :alpha_upper }) }

      it 'generates a key with the new format and char_pool' do
        key_gen.format = 'nnn-aaa'
        key_gen.char_pool = { 'n' => :numeric, 'a' => :alpha_lower }
        expect(key_gen.generate).to match(/^\d{3}-[a-z]{3}$/)
      end
    end

    context 'when multiple keys are requested' do
      let(:new_keys) { Flexkey::Generator.new(format: 'aaaaa-nnnn/cc', char_pool: {
        'a' => :alpha_lower, 'n' => :numeric, 'c' => 'LMN' }).generate(5) }

      it 'generates the specified number of keys' do
        expect(new_keys.size).to eq(5)
      end

      it 'generates unique keys' do
        expect(new_keys.uniq.size).to eq(5)
      end

      it 'generates keys with the specified format' do
        expect(new_keys.count { |key| key =~ /^[a-z]{5}-\d{4}\/[LMN]{2}$/ }).to eq(5)
      end
    end

    it 'raises an exception when too many keys are requested' do
      expect {
        Flexkey::Generator.new(format: 'nnn', char_pool: {
          'n' => :numeric, 'a' => :alpha_upper }).generate(1001)
      }.to raise_error(Flexkey::GeneratorError, "There are only 1000 possible keys")
    end
  end
end
