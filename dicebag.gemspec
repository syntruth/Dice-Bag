Gem::Specification.new do |s|
  s.metadata['rubygems_mfa_required'] = 'true'
  s.name        = 'dicebag'
  s.version     = File.read('VERSION').strip
  s.licenses    = ['MIT']
  s.summary     = 'Dice Bag: Ruby Dice Rolling Library'
  s.description = 'A very flexible dice rolling library for Ruby.'
  s.authors     = ['Randy "syntruth" Carnahan']
  s.email       = 'syntruth@gmail.com'
  s.homepage    = 'https://github.com/syntruth/Dice-Bag'
  s.required_ruby_version = '>= 2.7.1'
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib', 'lib/systems']
  s.executables << 'dicebag'
  s.add_runtime_dependency 'parslet', '~> 1.4', '>= 1.4.0'
end
