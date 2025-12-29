#
# Be sure to run `pod lib lint ReerCodable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReerCodable'
  s.version          = '0.0.3'
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
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_BUILD_DIR}/ReerCodable/MacroPlugin/ReerCodableMacros#ReerCodableMacros'
  }
  
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_BUILD_DIR}/ReerCodable/MacroPlugin/ReerCodableMacros#ReerCodableMacros'
  }
  
  # Download prebuilt universal macro plugin from GitHub Release
  script = <<-SCRIPT
    set -e
        
    PLUGIN_DIR="${PODS_BUILD_DIR}/ReerCodable/MacroPlugin"
    PLUGIN_NAME="ReerCodableMacros"
    VERSION="#{s.version}"
    DOWNLOAD_URL="https://github.com/reers/ReerCodable/releases/download/${VERSION}/${PLUGIN_NAME}.zip"
    
    # Check if plugin already exists
    if [ -x "${PLUGIN_DIR}/${PLUGIN_NAME}" ]; then
      echo "Macro plugin already exists, skipping download."
      exit 0
    fi
    
    mkdir -p "${PLUGIN_DIR}"
    
    echo "Downloading prebuilt macro plugin from ${DOWNLOAD_URL}..."
    
    if curl -L -f --connect-timeout 3 --max-time 60 -o "${PLUGIN_DIR}/${PLUGIN_NAME}.zip" "${DOWNLOAD_URL}"; then
      unzip -o "${PLUGIN_DIR}/${PLUGIN_NAME}.zip" -d "${PLUGIN_DIR}"
      rm -f "${PLUGIN_DIR}/${PLUGIN_NAME}.zip"
      chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
      echo "Successfully downloaded prebuilt macro plugin"
      file "${PLUGIN_DIR}/${PLUGIN_NAME}"
    else
      echo "Warning: Failed to download prebuilt macro plugin, will build from source..."
      
      # Fallback: build from source
      env -i PATH="$PATH" "$SHELL" -l -c "swift build -c release --package-path \\"${PODS_TARGET_SRCROOT}\\" --build-path \\"${PODS_BUILD_DIR}/ReerCodable\\" --product ReerCodableMacros"
      cp "${PODS_BUILD_DIR}/ReerCodable/release/ReerCodableMacros-tool" "${PLUGIN_DIR}/${PLUGIN_NAME}"
      chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
      echo "Built macro plugin from source"
      file "${PLUGIN_DIR}/${PLUGIN_NAME}"
    fi
  SCRIPT

  s.script_phase = {
    :name => 'Download ReerCodableMacros Plugin',
    :script => script,
    :execution_position => :before_compile
  }

end
