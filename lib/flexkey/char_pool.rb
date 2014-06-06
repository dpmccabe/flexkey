module Flexkey
  class CharPoolError < StandardError; end

  module CharPool
    extend self

    # Generates an array of characters of the specified types and proportions
    #
    # @param arg [Hash{ Symbol, String => Fixnum }, Symbol, String] a single character type or a
    #   hash of several character types and their proportions
    #
    # @return [Array<String>] the requested character pool
    #
    # @example
    #   Flexkey::CharPool.generate(:numeric)
    #   Flexkey::CharPool.generate('XYZ01234')
    #   Flexkey::CharPool.generate({ numeric: 0.25, alpha_upper: 0.75 })
    #   Flexkey::CharPool.generate({ alpha_lower_clear: 1, alpha_upper_clear: 3 })
    #   Flexkey::CharPool.generate({ 'AEIOU' => 1, 'BCDFGHJKLMNPQRSTVWXYZ' => 1, symbol: 0.5 })
    def generate(arg)
      if arg.is_a?(Hash)
        # Extract character types and proportions.
        char_arrays = arg.keys.map { |t| single_pool(t) }
        char_props = arg.values.each do |p|
          raise CharPoolError.new("Invalid char_pool proportion #{p.inspect}") unless
            p.is_a?(Numeric) && p >= 0
        end

        # Standardize the proportions if they don't sum to 1.
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
    #
    # @example
    #   Flexkey::CharPool.available_char_types
    def available_char_types
      character_types.keys
    end

    # Provides a list of the available built-in character pool types with the characters of each
    #   type.
    #
    # @return [Hash{ Symbol => String }] a hash of character pool types and their characters
    #
    # @example
    #   Flexkey::CharPool.available_char_pools
    def available_char_pools
      character_types.inject({}) { |acc, (k, v)| acc[k] = v.join; acc }
    end

    private

    def character_types
      {
        alpha_upper: 'A'.upto('Z').to_a,
        alpha_lower: 'a'.upto('z').to_a,
        numeric: '0'.upto('9').to_a,
        alpha_upper_clear: 'A'.upto('Z').to_a - 'IOS'.chars.to_a,
        alpha_lower_clear: 'a'.upto('z').to_a - 'ilos'.chars.to_a,
        numeric_clear: '2346789'.chars.to_a,
        symbol: "!@#\$%^&*;:()_+-=[]{}\\|'\",.<>/?".chars.to_a,
        basic_symbol: '!@#$%^&*;:'.chars.to_a
      }
    end

    # Return an array of characters from either a custom pool or a built-in type
    def single_pool(char_type)
      if char_type.respond_to?(:chars)
        if char_type.empty?
          raise CharPoolError.new('A custom char_pool was blank')
        else
          char_type.chars.to_a
        end
      elsif character_types.keys.include?(char_type)
        character_types[char_type]
      else
        raise CharPoolError.new("Invalid char_pool #{char_type.inspect}")
      end
    end

    # Return a flat array of characters from the provided character pools and proportions
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
