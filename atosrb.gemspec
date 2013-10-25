Gem::Specification.new do |s|
  s.name        = 'atosrb'
  s.version     = '1.0.0'
  s.date        = '2013-10-25'
  s.summary     = "Utility/wrapper for `atos` to symbolicate OS X crashlogs"
  s.description = "This utility is a wrapper for `atos` command. It parses crashlog and symbolicates it with atos command"
  s.authors     = ["Mārtiņš Poļakovs"]
  s.email       = 'mp@foo.lv'
  s.files       = ["lib/atos_wrapper.rb"]
  s.executables << 'atosrb'
  s.license       = 'MIT'

  s.add_runtime_dependency 'plist'
end