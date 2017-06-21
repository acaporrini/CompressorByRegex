# CompressorByRegex

A gem for parsing an array of strings and reduce it into an array of regular expressions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'compressor_by_regex'
```

And then execute:

    $ bundle

## Usage
```ruby
"require compressor_by_regex"

parser = CompressorByRegex::Parser.new(["0010","0012", "0022", "1005", "0023", "0024", "0027","1001", "0013", "1002"])
regular_expressions = parser.parse # --> ["/^0010$/", "/^001[23]$/", "/^002[2-4]$/", "/^0027$/", "/^100[12]$/", "/^1005$/"]

# Using the generated regex array
regular_expressions.none? {|regex| regex.to_regexp =~ "0023"}
```


