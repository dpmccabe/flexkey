module Flexkey
  class GeneratorError < StandardError; end

  class Generator
    # @return [String] the format of the keys to be generated
    attr_accessor :format

    # @return [Hash{ String => Symbol, String }] a pool of available character types specified in the format
    attr_accessor :char_pool

    # @return [Fixnum] the number of possible keys for a Flexkey object with given format and character pool
    attr_reader :n_possible_keys

    # Initializes and validates a new Flexkey key generator.
    #
    # @param format [String] the format of the keys to be generated
    # @param char_pool [Hash{ String => Symbol, String }] a pool of available character types specified in the `format`
    # @return [Flexkey] the Flexkey instance
    # @example
    #   Flexkey.new(format: 'nnn-aaa', char_pool: { 'n' => :numeric, 'a' => :alpha_upper_clear })
    #   Flexkey.new(format: 'ccccc-ccccc', char_pool: { 'c' => { alpha_upper: 0.75, alpha_lower: 0.25 } })
    #   Flexkey.new(format: 'key_#######', char_pool: { '#' => :numeric_clear })
    #   Flexkey.new(format: 'a-nnnn', char_pool: { 'a' => :alpha_upper, 'n' => '12345' })
    def initialize(args = {})
      @format, @char_pool = args[:format], args[:char_pool]
      validate!
      set_char_pool
      calculate_n_possible_keys
    end

    def format=(new_format)
      @format = new_format
      validate!
      calculate_n_possible_keys
    end

    def char_pool=(new_char_pool)
      @char_pool = new_char_pool
      validate!
      set_char_pool
      calculate_n_possible_keys
    end

    # Generates a single key or an array of `n` keys.
    #
    # @param n [Integer] the number of keys to generate
    # @return [String] a single key
    # @return [Array<String>] `n` keys
    def generate(n = 1)
      validate_n!(n)

      if n == 1
        generate_one
      elsif n > 1
        keys = []
        new_key = nil

        n.times do
          loop do
            new_key = generate_one
            break unless keys.include?(new_key)
          end

          keys << new_key
        end

        keys
      end
    end

    private

    def validate!
      raise GeneratorError.new('format is required') if @format.nil? || @format.empty?
      raise GeneratorError.new('char_pool is required') if @char_pool.nil? || @char_pool.empty?
      raise GeneratorError.new('char_pool letters must each be strings of length 1') unless @char_pool.keys.all? { |letter| letter.is_a?(String) && letter.length == 1 }
      raise GeneratorError.new('No char_pool letters present in format') if (@format.chars.to_a & @char_pool.keys).empty?
    end

    def set_char_pool
      @_char_pool = @char_pool.inject({}) { |h, (k, v)| h[k] = CharPool.new(v).pool; h }
    end

    def calculate_n_possible_keys
      @n_possible_keys = @format.chars.to_a.map { |c| @_char_pool[c].nil? ? 1 : @_char_pool[c].size }.inject(:*)
    end

    def generate_one
      @format.chars.to_a.map { |c| @_char_pool[c].nil? ? c : @_char_pool[c].sample }.join
    end

    def validate_n!(n)
      raise GeneratorError.new("There are only #{@n_possible_keys} possible keys") if n > @n_possible_keys
    end
  end
end
