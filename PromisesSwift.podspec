Pod::Spec.new do |s|
  s.name        = 'PromisesSwift'
  s.version     = '2.4.0'
  s.authors     = 'Google Inc.'
  s.license     = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.homepage    = 'https://github.com/google/promises'
  s.source      = { :git => 'https://github.com/google/promises.git', :tag => s.version }
  s.summary     = 'Synchronization construct for Swift'
  s.description = <<-DESC

  Promises is a modern framework that provides a synchronization construct for
  Swift to facilitate writing asynchronous code.
                     DESC

  # Ensure developers won't hit CocoaPods/CocoaPods#11402 with the resource
  # bundle for the privacy manifest.
  s.cocoapods_version = '>= 1.12.0'

  s.ios.deployment_target  = '9.0'
  s.osx.deployment_target  = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.visionos.deployment_target = '1.0'
  s.swift_versions = ['5.0', '5.2']

  s.module_name = 'Promises'
  s.source_files = "Sources/#{s.module_name}/*.{swift}"
  s.resource_bundle = {
    "#{s.module_name}_Privacy" => "Sources/#{s.module_name}/Resources/PrivacyInfo.xcprivacy"
  }
  s.dependency 'PromisesObjC', "#{s.version}"
end
