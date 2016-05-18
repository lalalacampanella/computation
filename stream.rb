require './lambda.rb'

ZEROS         = Z[-> f { UNSHIFT[f][ZERO] }]
UPWARDS_OF    = Z[-> f { -> n { UNSHIFT[-> x { f[INCREMENT[n]][x] }][n] } }]
MULTIPLES_OF  =
  -> m {
  Z[-> f {
    -> n { UNSHIFT[->x { f[ADD[m][n]][x] }][n] }
  }][m]
}

puts(to_array(ZEROS,5).map { |p| to_interger(p) }.inspect)
puts(to_array(UPWARDS_OF[ZERO], 5).map { |p| to_interger(p) }.inspect)
puts(to_array(MULTIPLES_OF[TWO], 10).map { |p| to_interger(p) }.inspect)
