#
# Be sure to run `pod lib lint ReerCodable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReerCodable'
  s.version          = '1.4.5'
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

  s.source_files = 'Sources/ReerCodable/**/*'
  
  s.preserve_paths = ["Package.swift", "Sources/ReerCodableMacros"]
  
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/ReerCodable/release/ReerCodableMacros-tool#ReerCodableMacros'
  }
  
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/ReerCodable/release/ReerCodableMacros-tool#ReerCodableMacros'
  }
  
  script = <<-SCRIPT
    env -i PATH="$PATH" "$SHELL" -l -c "swift build -c release --package-path \\"$PODS_TARGET_SRCROOT\\" --build-path \\"${PODS_BUILD_DIR}/ReerCodable\\""
  SCRIPT
  
  s.script_phase = {
    :name => 'Build ReerCodable macro plugin',
    :script => script,
    :execution_position => :before_compile,
    :output_files => [
      '$(PODS_BUILD_DIR)/ReerCodable/release/ReerCodableMacros-tool'
    ]
  }

end
