require './main'
bc = BayesianClassifier.new('word_class.db')
cl=bc.classification ARGV[0]
cl.each do |key,val|
  puts "#{key}:#{val}"
end
