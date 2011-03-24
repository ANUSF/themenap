Gem::Specification.new do |s|
  s.name        = 'themenap'
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Olaf Delgado-Friedrichs', 'ANUSF']
  s.email       = ['olaf.delgado-friedrichs@anu.edu.au']
  s.homepage    = 'http://sf.anu.edu.au/~oxd900'
  s.required_rubygems_version = '>= 1.3.5'
  s.files        = Dir.glob('{app,lib,config}/**/*') + %w(MIT-LICENSE)
  s.require_path = 'lib'

  s.add_dependency 'nokogiri'

  s.summary     = "A Rails engine that 'steals' another application's theme."
  s.description = %q{
    A Rails engine that 'steals' another application's layout and
    styling. Just add the gem and their theme is your theme.
  }
end
