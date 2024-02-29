Gem::Specification.new do |s|
  s.name        = 'dicebag'
  s.version     = '3.3.0'
  s.date        = '2016-04-25'
  s.licenses    = ['MIT']
  s.summary     = 'Dice Bag: Ruby Dice Rolling Library'
  s.description = 'A very flexible dice rolling library for Ruby.'
  s.authors     = ['SynTruth']
  s.email       = 'syntruth@gmail.com'
  s.homepage    = 'https://github.com/syntruth/Dice-Bag'

  s.required_ruby_version = '>= 2.7.1'

  s.files = Dir['lib/**/*.rb']

  s.require_paths = ['lib', 'lib/systems']

  s.executables << 'dicebag'

  s.add_runtime_dependency 'parslet', '~> 1.4', '>= 1.4.0'
end
