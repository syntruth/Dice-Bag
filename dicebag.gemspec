Gem::Specification.new do |s|
  s.name        = 'dicebag'
  s.version     = '3.2.0'
  s.date        = '2016-04-18'
  s.summary     = 'Dice Bag: Ruby Dice Rolling Library'
  s.description = 'A very flexible dice rolling library for Ruby.'
  s.authors     = ['SynTruth']
  s.email       = 'syntruth@gmail.com'
  s.homepage    = 'https://github.com/syntruth/Dice-Bag'

  s.files = Dir['lib/**/*.rb']

  s.add_runtime_dependency 'parslet', ['>= 1.4.0']
end
