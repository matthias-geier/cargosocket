Gem::Specification.new do |s|
  s.name = "cargosocket"
  s.version = '0.1.0'
  s.summary = "Middleware to create a websocket service"
  s.author = "Matthias Geier"
  s.homepage = "https://github.com/matthias-geier/cargosocket"
  s.licenses = ['BSD-2']
  s.require_path = 'lib'
  s.files = Dir['lib/**/*.rb'] + [ "LICENSE.md" ]
  s.executables = []
  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency('em-websocket', '>= 0.5.1')
  s.add_runtime_dependency('cargobull', '>= 0.3')
end
