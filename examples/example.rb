require 'bundler/setup'

require 'pry'
require 'awesome_print'

def exemplify(description, object)
  puts "\n::: #{description} ".ljust(50, ":::")
  ap object, indent: -2
end
