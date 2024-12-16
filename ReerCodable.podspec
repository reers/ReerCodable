#
# Be sure to run `pod lib lint ReerCodable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReerCodable'
  s.version          = '1.0.0'
  s.summary          = 'Codable extensions using Swift Macro'

  s.description      = <<-DESC
  Enhancing Swift's Codable Protocol Using Macros: A Declarative Approach to Serialization
                       DESC

  s.homepage         = 'https://github.com/reers/ReerCodable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Asura19' => 'x.rhythm@qq.com' }
  s.source           = { :git => 'https://github.com/reers/ReerCodable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = "10.15"
  s.watchos.deployment_target = "6.0"
  s.tvos.deployment_target = "13.0"
  s.visionos.deployment_target = "1.0"
  
  s.swift_versions = '5.10'

  s.source_files = 'Sources/**/*'
  s.preserve_paths = ["Sources/Resources/ReerCodableMacros"]
  s.exclude_files = 'Sources/ReerCodableMacros'
  
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-enable-experimental-feature SymbolLinkageMarkers -Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/Sources/Resources/ReerCodableMacros#ReerCodableMacros'
  }
  
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-enable-experimental-feature SymbolLinkageMarkers -Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/Sources/Resources/ReerCodableMacros#ReerCodableMacros'
  }

end
