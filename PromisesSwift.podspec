Pod::Spec.new do |s|
  s.name        = 'PromisesSwift'
  s.version     = '1.2.8'
  s.authors     = 'Google Inc.'
  s.license     = { :type => 'Apache', :file => 'LICENSE' }
  s.homepage    = 'https://github.com/google/promises'
  s.source      = { :git => 'https://github.com/google/promises.git', :tag => s.version }
  s.summary     = 'Synchronization construct for Swift'
  s.description = <<-DESC

  Promises is a modern framework that provides a synchronization construct for
  Swift to facilitate writing asynchronous code.
                     DESC

  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target  = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.module_name = 'Promises'
  s.source_files = "Sources/#{s.module_name}/*.{swift}"
  s.dependency 'PromisesObjC', "#{s.version}"
end
