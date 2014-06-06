# Flexkey

Flexkey is a Ruby gem for generating unique, random strings for use as product keys, redemption codes, invoice numbers, passwords, etc.

## Usage

#### Basic usage

Instantiate a new generator with `Flexkey::Generator.new` and provide a `format` and `char_pool`. Then, generate single or multiple keys with the `generate` method:

```ruby
keygen = Flexkey::Generator.new(format: 'aaaa-aa', char_pool: { 'a' => :alpha_upper })
# => #<Flexkey::Generator @format="aaaa-aa", @char_pool={"a"=>:alpha_upper}, @n_possible_keys=308915776>
keygen.generate
# => "KBND-NR"
keygen.generate(3)
# => ["IVXT-LB", "BFZB-LM", "WIVG-ZJ"]
```

In this example, Flexkey generates a key by replacing each instance of `'a'` in the string `'aaaa-aa'` with a character
randomly drawn from a pool of uppercase letters and leaves unspecified characters (i.e. `'-'`) alone. There are several built-in types available:

| **Character type** | **Description** |
|:-------------------:|:--------------------------------------------------------:|
| `alpha_upper` | uppercase letters |
| `alpha_lower` | lowercase letters |
| `numeric` | numerals |
| `alpha_upper_clear` | `alpha_upper` without ambiguous letters ("S", "O", etc.) |
| `alpha_lower_clear` | `alpha_lower` without ambiguous letters ("l", "O", etc.) |
| `numeric_clear` | `numeric` without ambiguous numerals ("0", "1", and "5") |
| `symbol` | symbols on a standard U.S. keyboard |
| `basic_symbol` | basic symbols on a standard U.S. keyboard |

##### Examples

```ruby
Flexkey::Generator.new(format: 'a-nnnn', char_pool: {
  'a' => :alpha_upper, 'n' => :numeric
}).generate
# => "Y-1145"
```

```ruby
Flexkey::Generator.new(format: 'SN-nnnnnnnnn', char_pool: {
  'n' => :numeric
}).generate
# => "SN-181073470"
```

```ruby
Flexkey::Generator.new(format: 'AA.aa.nn.ss', char_pool: {
  'A' => :alpha_upper_clear, 'a' => :alpha_lower_clear, 'n' => :numeric_clear,
  's' => :basic_symbol
}).generate
# => "MX.mh.33.*:"
```

You can also specify a custom string instead of using a built-in type.

```ruby
Flexkey::Generator.new(format: 'annn/c', char_pool: {
  'a' => :alpha_upper, 'n' => :numeric, 'c' => 'LMN'
}).generate(5)
# => ["X905/N", "F865/L", "M423/N", "V564/L", "V874/M"]
```

#### Selecting from multiple character types

To replace a character in the `format` from a pool of multiple character types, specify the types and proportions in the `char_pool`. For example, to generate keys of length 10 where each character is randomly selected from a pool of uppercase letters and numerals with equal proportions, do the following:

```ruby
Flexkey::Generator.new(format: '..........', char_pool: {
  '.' => { alpha_upper: 0.5, numeric: 0.5 }
}).generate(5)
# => ["OXAEXC2O87", "3D95JXQ60P", "8F28OX31Y8", "65ZY7IM6TL", "B971Q602SO"]
```




## Installation

Add this line to your application's Gemfile:

    gem 'flexkey'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flexkey

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
