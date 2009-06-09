# Array#<=> exists, but I want to be able to compare them as in [2, 2008] < [4, 2008].
class Array
  include Comparable
end