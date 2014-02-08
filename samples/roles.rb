#
# This example was ported from
# https://metacpan.org/pod/Moose::Cookbook::Roles::Comparable_CodeReuse

require 'moosex'

module Eq
	include MooseX.init( warnings: false)

	requires :equal

	def no_equal(other)
		! self.equal(other)
	end
end

module Valuable
	include MooseX

	has value: { is: :ro, requires: true } 
end	

class Currency
	include Valuable
	include Eq  # will warn unless disable_warnings was called.
              # to avoid warnings, you should include after  
	            # define all required modules,

	def equal(other)
		self.value == other.value
	end

	# include Eq            # warning safe include
end

class Comparator
	include MooseX

	has compare_to: { 
		is: :ro,
		isa: Eq,
		handles: Eq, 
	}
end

module Wrapper
	include Eq
end

class WrongClass
	include Wrapper

	has one: { is: :rw }
end

c1 = Currency.new( value: 12 )
c2 = Currency.new( value: 12 )
c3 = Currency.new( value: 24 )

p c1.equal(c2) # true
p c1.equal(c3) # false

p Comparator.new(compare_to: c1).no_equal(c2) # false
p Comparator.new(compare_to: c1).no_equal(c3) # true

begin
  WrongClass.new(one: 1, two: 2) # will raise exception
rescue => e
  puts "will raise exception #{e}"
end
