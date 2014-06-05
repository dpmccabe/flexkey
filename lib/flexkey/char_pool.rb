module Flexkey
  class CharPoolError < StandardError; end

  module CharPool
    extend self

    CHARACTERS = {
      alpha_upper: 'A'.upto('Z').to_a,
      alpha_lower: 'a'.upto('z').to_a,
      numeric: '0'.upto('9').to_a,
      alpha_upper_clear: 'A'.upto('Z').to_a - 'IOS'.chars.to_a,
      alpha_lower_clear: 'a'.upto('z').to_a - 'ilos'.chars.to_a,
      numeric_clear: '2346789'.chars.to_a,
      symbol: "!@#\$%^&*;:()_+-=[]{}\\|'\",.<>/?".chars.to_a,
      basic_symbol: '!@#$%^&*;:'.chars.to_a
    }

    def generate(arg)
      if arg.is_a?(Hash)
        char_arrays = arg.keys.map { |t| single_pool(t) }
        char_props = arg.values.each { |p| raise CharPoolError.new("Invalid char_pool proportion #{p.inspect}") unless p.is_a?(Numeric) && p >= 0 }

        # Correct proportions if they don't sum to 1
        total_prop = char_props.inject(:+).to_f
        char_props = char_props.map { |prop| prop / total_prop }

        multiple_pool(char_arrays, char_props)
      else
        single_pool(arg)
      end
    end

    # Provides a list of the available built-in character pool types.
    #
    # @return [Array<Symbol>] the list of character pool types
    def available_char_types
      CHARACTERS.keys
    end

    # Provides a list of the available built-in character pool types with the characters of each type.
    #
    # @return [Hash{ Symbol => String }] a hash of character pool types and their characters
    def available_char_pools
      CHARACTERS.inject({}) { |acc, (k, v)| acc[k] = v.join; acc }
    end

    private

    def single_pool(char_type)
      if char_type.respond_to?(:chars)
        if char_type.empty?
          raise CharPoolError.new('A custom char_pool was blank')
        else
          char_type.chars.to_a
        end
      elsif CHARACTERS.keys.include?(char_type)
        CHARACTERS[char_type]
      else
        raise CharPoolError.new("Invalid char_pool #{char_type.inspect}")
      end
    end

    def multiple_pool(char_arrays, char_props)
      # Compute LCM of sizes of char type arrays
      char_array_sizes = char_arrays.map(&:size)
      char_array_sizes_lcm = char_array_sizes.inject(:lcm)

      # Compute approximate number of multiples needed for each char type array
      char_array_multiples = char_array_sizes.zip(char_props).map { |arr|
        (char_array_sizes_lcm / arr[0] * arr[1] * 100).round }

      # Construct combined array of all char types with correct proportions
      char_array_multiples_gcd = char_array_multiples.inject(:gcd)
      char_arrays_mult = char_arrays.zip(char_array_multiples).map { |arr|
        arr[0] * (arr[1] / char_array_multiples_gcd) }

      char_arrays_mult.flatten    
    end
  end
end
