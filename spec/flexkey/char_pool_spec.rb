require 'spec_helper'

module CharPoolSpecHelpers
  def cpj(arg)
    Flexkey::CharPool.generate(arg).join
  end
end

describe Flexkey::CharPool do
  include CharPoolSpecHelpers

  describe 'utility methods' do
    it 'should provide a list of available character types' do
      expect(Flexkey::CharPool.available_char_types).to eq([:alpha_upper, :alpha_lower, :numeric, :alpha_upper_clear, :alpha_lower_clear, :numeric_clear, :symbol, :basic_symbol])
    end

    it 'should provide a list of character pools for available character types' do
      expect(Flexkey::CharPool.available_char_pools).to eq({
        alpha_upper: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        alpha_lower: 'abcdefghijklmnopqrstuvwxyz',
        numeric: '0123456789',
        alpha_upper_clear: 'ABCDEFGHJKLMNPQRTUVWXYZ',
        alpha_lower_clear: 'abcdefghjkmnpqrtuvwxyz',
        numeric_clear: '2346789',
        symbol: "!@\#$%^&*;:()_+-=[]{}\\|'\",.<>/?",
        basic_symbol: "!@\#$%^&*;:"
      })
    end
  end

  context 'when a single type is requested' do
    describe 'validations' do
      it 'raises an exception for an unknown character pool symbol' do
        expect { Flexkey::CharPool.generate(:bad) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool :bad')
      end

      it 'raises an exception for an nil character pool symbol' do
        expect { Flexkey::CharPool.generate(nil) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool nil')
      end

      it 'raises an exception for a non-symbol type' do
        expect { Flexkey::CharPool.generate(123) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool 123')
      end

      it 'raises an exception for a blank custom type' do
        expect { Flexkey::CharPool.generate('') }.to raise_error(Flexkey::CharPoolError, 'A custom char_pool was blank')
      end
    end

    it 'generates an uppercase alphabetical character pool' do
      expect(cpj(:alpha_upper)).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    end

    it 'generates a lowercase alphabetical character pool' do
      expect(cpj(:alpha_lower)).to eq('abcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a numeric character pool' do
      expect(cpj(:numeric)).to eq('0123456789')
    end

    it 'generates an uppercase and clear alphabetical character pool' do
      expect(cpj(:alpha_upper_clear)).to eq('ABCDEFGHJKLMNPQRTUVWXYZ')
    end

    it 'generates a lowercase and clear alphabetical character pool' do
      expect(cpj(:alpha_lower_clear)).to eq('abcdefghjkmnpqrtuvwxyz')
    end

    it 'generates a numeric and clear character pool' do
      expect(cpj(:numeric_clear)).to eq('2346789')
    end

    it 'generates a full symbol character pool' do
      expect(cpj(:symbol)).to eq("!@#\$%^&*;:()_+-=[]{}\\|'\",.<>/?")
    end

    it 'generates a basic symbol character pool' do
      expect(cpj(:basic_symbol)).to eq('!@#$%^&*;:')
    end

    it 'generates a custom character pool' do
      expect(cpj('ABC123')).to eq('ABC123')
    end
  end

  context 'when multiple types are requested' do
    describe 'validations' do
      it 'raises an exception for an unknown character pool symbol' do
        expect { Flexkey::CharPool.generate({ alpha_upper: 0.5, bad: 0.5 }) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool :bad')
      end

      it 'raises an exception for a non-symbol type' do
        expect { Flexkey::CharPool.generate({ alpha_upper: 0.5, 123 => 0.5 }) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool 123')
      end

      it 'raises an exception for a negative proportion' do
        expect { Flexkey::CharPool.generate({ alpha_upper: 0.5, numeric: -0.5 }) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool proportion -0.5')
      end

      it 'raises an exception for a non-numeric proportion' do
        expect { Flexkey::CharPool.generate({ alpha_upper: 0.5, numeric: 'test' }) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool proportion "test"')
      end

      it 'raises an exception for missing proportion' do
        expect { Flexkey::CharPool.generate({ alpha_upper: 0.5, numeric: nil }) }.to raise_error(Flexkey::CharPoolError, 'Invalid char_pool proportion nil')
      end
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in equal proportions' do
      expect(cpj({ alpha_upper: 0.5, alpha_lower: 0.5 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in equal proportions (by odds)' do
      expect(cpj({ alpha_upper: 1, alpha_lower: 1 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in a 3:1 proportion' do
      expect(cpj({ alpha_upper: 0.75, alpha_lower: 0.25 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in a 3:1 proportion (by odds)' do
      expect(cpj({ alpha_upper: 3, alpha_lower: 1 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in a 1:3 proportion' do
      expect(cpj({ alpha_upper: 0.25, alpha_lower: 0.75 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in a 0:1 proportion' do
      expect(cpj({ alpha_upper: 0, alpha_lower: 99 })).to eq('abcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase and lowercase alphabetical types in equal proportions not summing to 1' do
      expect(cpj({ alpha_upper: 0.2, alpha_lower: 0.2 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    end

    it 'generates a pool of uppercase alphabetical and numeric character types in equal proportions' do
      expect(cpj({ alpha_upper: 0.5, numeric: 0.5 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
    end

    it 'generates a pool of numeric and a custom type in equal proportions' do
      expect(cpj({ numeric: 0.5, 'ABCDE' => 0.5 })).to eq('0123456789ABCDEABCDE')
    end

    it 'generates a pool of uppercase and another custom type in equal proportions' do
      expect(cpj({ alpha_upper: 1, '0123456789!@#' => 1 })).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#0123456789!@#')
    end

    it 'generates a pool of two custom types in a 1:4 proportion' do
      expect(cpj({ 'ABCD' => 1, 'WXYZ' => 4 })).to eq('ABCDWXYZWXYZWXYZWXYZ')
    end
  end
end
