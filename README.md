## Flexkey

Flexkey is a Ruby gem for generating unique, random strings for use as product keys, redemption codes, invoice numbers, passwords, etc.

### Installation

Add this line to your application's Gemfile:

    gem 'flexkey'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flexkey

##### Dependencies

None. Flexkey has been tested with Ruby 1.9.3 and 2.0.

### Usage

##### Basic usage

Instantiate a new generator with `Flexkey::Generator.new` and provide a `format` and `char_pool`. Then, generate a single key or multiple unique keys with the `generate` method:

```ruby
keygen = Flexkey::Generator.new(format: 'aaaa-aa', char_pool: { 'a' => :alpha_upper })
# => #<Flexkey::Generator @format="aaaa-aa", @char_pool={"a"=>:alpha_upper}, @n_possible_keys=308915776>
keygen.generate
# => "KBND-NR"
keygen.generate(3)
# => ["IVXT-LB", "BFZB-LM", "WIVG-ZJ"]
```

In this example, Flexkey generates a key by replacing each instance of `'a'` in the string `'aaaa-aa'` with a character
randomly drawn from a pool of uppercase letters while leaving unspecified characters (i.e. `'-'`) alone.

Since you're most likely persisting generated keys in a database, even though `generate(n)` will return `n` _unique_ keys, you'll still want to validate them for uniqueness against keys you've previously saved.

##### Built-in character types

| **Character type** | **Description** |
|-------------------|--------------------------------------------------------|
| alpha_upper | uppercase letters |
| alpha_lower | lowercase letters |
| numeric | numerals |
| alpha_upper_clear | alpha_upper without ambiguous letters ("S", "O", etc.) |
| alpha_lower_clear | alpha_lower without ambiguous letters ("l", "O", etc.) |
| numeric_clear | numeric without ambiguous numerals ("0", "1", and "5") |
| symbol | symbols on a standard U.S. keyboard |
| basic_symbol | basic symbols on a standard U.S. keyboard |

The names and characters present in each type can be retrieved as such:

```ruby
Flexkey::CharPool.available_char_types
# => [:alpha_upper, :alpha_lower, :numeric, :alpha_upper_clear, :alpha_lower_clear, :numeric_clear, :symbol, :basic_symbol]
Flexkey::CharPool.available_char_pools
# => {:alpha_upper=>"ABCDEFGHIJKLMNOPQRSTUVWXYZ", :alpha_lower=>"abcdefghijklmnopqrstuvwxyz", :numeric=>"0123456789", :alpha_upper_clear=>"ABCDEFGHJKLMNPQRTUVWXYZ", :alpha_lower_clear=>"abcdefghjkmnpqrtuvwxyz", :numeric_clear=>"2346789", :symbol=>"!@\#$%^&*;:()_+-=[]{}\\|'\",.<>/?", :basic_symbol=>"!@\#$%^&*;:"}
```

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
  'A' => :alpha_upper_clear, 'a' => :alpha_lower_clear, 'n' => :numeric_clear, 's' => :basic_symbol
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

```ruby
Flexkey::Generator.new(format: 'mnnnnnnn', char_pool: {
  'm' => '123456789', 'n' => :numeric
}).generate(5)
# => ["45862188", "23054329", "36248220", "56044911", "49873464"]
```

##### Selecting from multiple character types

To replace a character in the `format` from a pool of multiple character types, specify the both the types and proportions in the `char_pool`. For example, to generate keys of length 10 where each character is randomly selected from a pool of uppercase letters and numerals with equal proportions, do the following:

```ruby
Flexkey::Generator.new(format: '..........', char_pool: {
  '.' => { alpha_upper: 0.5, numeric: 0.5 }
}).generate(5)
# => ["OXAEXC2O87", "3D95JXQ60P", "8F28OX31Y8", "65ZY7IM6TL", "B971Q602SO"]
```

You can specify proportions with any positive numbers:

```ruby
Flexkey::Generator.new(format: 'U-ccccc-ccccc', char_pool: {
  'U' => :alpha_upper_clear, 'c' => { numeric_clear: 1, alpha_upper_clear: 7 }
}).generate(5)
# => ["H-KYLYK-DQLK3", "U-7QUXV-6DXNW", "X-REYAX-LL489", "L-8ABNJ-ZW3A7", "M-TPVTW-VEMTE"]
```

```ruby
Flexkey::Generator.new(format: 'UUUUU.LLLLL', char_pool: {
  'U' => { 'WXYZ' => 3, 'FGH' => 1 }, 'L' => :alpha_lower_clear
}).generate(5)
# => ["XZYYF.kwkth", "HHFYW.nkpdr", "WXXGW.fvyeu", "HWFXW.xzgeq", "WXWXW.twrdk"]
```

##### Number of possible keys

Flexkey will raise an exception if you try to request more keys than are possible with the `format` you provided:

```ruby
keygen = Flexkey::Generator.new(format: 'annn', char_pool: {
  'a' => :alpha_upper, 'n' => :numeric
})
keygen.generate(3)
# => ["F202", "U811", "W802"]
keygen.generate(26001)
# Flexkey::GeneratorError: There are only 26000 possible keys
keygen.n_possible_keys
# => 26000
```

The instance method `n_possible_keys` is available for reference.

##### CharPool

If you're only interested in using the proportional sampling feature of Flexkey and will generate keys yourself, use `Flexkey::CharPool.generate` with a single hash argument:

```ruby
char_pool = Flexkey::CharPool.generate({ alpha_upper: 0.75, numeric: 0.25 })
10.times.map { char_pool.sample }.join
=> "XC3RPKKWKA"
```

### Additional documentation

Somewhere.

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
