Pod::Spec.new do |s|
  s.name        = 'PromisesObjC'
  s.version     = '1.2.9'
  s.authors     = 'Google Inc.'
  s.license     = { :type => 'Apache', :file => 'LICENSE' }
  s.homepage    = 'https://github.com/google/promises'
  s.source      = { :git => 'https://github.com/google/promises.git', :tag => s.version }
  s.summary     = 'Synchronization construct for Objective-C'
  s.description = <<-DESC

  Promises is a modern framework that provides a synchronization construct for
  Objective-C to facilitate writing asynchronous code.
                     DESC

  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target  = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.module_name = 'FBLPromises'
  s.prefix_header_file = false
  s.header_mappings_dir = "Sources/#{s.module_name}/include/"
  s.public_header_files = "Sources/#{s.module_name}/include/**/*.h"
  s.private_header_files = "Sources/#{s.module_name}/include/FBLPromisePrivate.h"
  s.source_files = "Sources/#{s.module_name}/**/*.{h,m}"
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => "\"${PODS_TARGET_SRCROOT}/Sources/#{s.module_name}/include\""
  }

  s.test_spec 'Tests' do |ts|
    # Note: Omits watchOS as a workaround since XCTest is not available to watchOS for now.
    # Reference: https://github.com/CocoaPods/CocoaPods/issues/8283, https://github.com/CocoaPods/CocoaPods/issues/4185.
    ts.platforms = {:ios => nil, :osx => nil, :tvos => nil}
    ts.source_files = "Tests/#{s.module_name}Tests/*.m",
                      "Sources/#{s.module_name}TestHelpers/include/#{s.module_name}TestHelpers.h"
  end
  s.test_spec 'PerformanceTests' do |ts|
    # Note: Omits watchOS as a workaround since XCTest is not available to watchOS for now.
    # Reference: https://github.com/CocoaPods/CocoaPods/issues/8283, https://github.com/CocoaPods/CocoaPods/issues/4185.
    ts.platforms = {:ios => nil, :osx => nil, :tvos => nil}
    ts.source_files = "Tests/#{s.module_name}PerformanceTests/*.m",
                      "Sources/#{s.module_name}TestHelpers/include/#{s.module_name}TestHelpers.h"
  end
end
