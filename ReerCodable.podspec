#
# Be sure to run `pod lib lint ReerCodable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReerCodable'
  s.version          = '1.5.0'
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
  
  s.preserve_paths = ["Package.swift", "Sources/ReerCodableMacros", "Tests", "MacroPlugin"]
  
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/MacroPlugin/ReerCodableMacros#ReerCodableMacros'
  }
  
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/MacroPlugin/ReerCodableMacros#ReerCodableMacros'
  }
  
  # Download prebuilt universal macro plugin from GitHub Release
  s.prepare_command = <<-CMD
    set -e
    
    PLUGIN_DIR="MacroPlugin"
    PLUGIN_NAME="ReerCodableMacros"
    VERSION="#{s.version}"
    DOWNLOAD_URL="https://github.com/reers/ReerCodable/releases/download/${VERSION}/${PLUGIN_NAME}"
    
    mkdir -p "${PLUGIN_DIR}"
    
    echo "Downloading prebuilt macro plugin from ${DOWNLOAD_URL}..."
    
    if curl -L -f -o "${PLUGIN_DIR}/${PLUGIN_NAME}" "${DOWNLOAD_URL}"; then
      chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
      echo "Successfully downloaded prebuilt macro plugin"
      file "${PLUGIN_DIR}/${PLUGIN_NAME}"
    else
      echo "Warning: Failed to download prebuilt macro plugin, will build from source..."
      
      # Fallback: build from source
      swift build -c release --package-path "." --product ReerCodableMacros
      cp ".build/release/ReerCodableMacros-tool" "${PLUGIN_DIR}/${PLUGIN_NAME}"
      chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
      echo "Built macro plugin from source"
      file "${PLUGIN_DIR}/${PLUGIN_NAME}"
    fi
  CMD

end
