# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Pantry' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings! 

  # Pods for Pantry
	pod 'MTBBarcodeScanner'
	pod 'Alamofire', '~> 4.0'
	pod 'AlamofireImage', '~> 3.2'
	pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
	pod 'PermissionScope'
	pod 'VersionTrackerSwift'
	pod 'DeviceKit', '~> 1.2'
	pod 'Firebase/Core'
	pod 'Firebase/Database'
	pod 'Firebase/Messaging'
	pod 'Firebase/Crash'
	pod 'Firebase/Auth'
	pod 'Firebase/Storage'
	pod 'Firebase/Invites'
	pod 'Firebase/DynamicLinks'
	pod 'FirebaseUI/Database', '~> 4.0'
	pod 'FirebaseUI/Storage', '~> 4.0'
	pod 'FirebaseUI/Auth', '~> 4.0'
	pod 'FirebaseUI/Google', '~> 4.0'
	pod 'FirebaseUI/Facebook', '~> 4.0'
	pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
	pod 'BarcodeScanner'
	
	# Extensions
	pod 'SwifterSwift'
		

		# UI
	pod 'UITextField+Shake', '~> 1.1'
	pod 'CDAlertView'
	pod 'JVFloatLabeledTextField'
	pod 'FoldingCell', '~> 2.0'

		# Menus
		
  target 'PantryTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PantryUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'GeoFire' then
      target.build_configurations.each do |config|
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] = "#{config.build_settings['FRAMEWORK_SEARCH_PATHS']} ${PODS_ROOT}/FirebaseDatabase/Frameworks/ $PODS_CONFIGURATION_BUILD_DIR/GoogleToolboxForMac"
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] = "#{config.build_settings['FRAMEWORK_SEARCH_PATHS']} ${PODS_ROOT}/FirebaseDatabase/Frameworks/ $PODS_CONFIGURATION_BUILD_DIR/GoogleToolboxForMac $PODS_CONFIGURATION_BUILD_DIR/nanopb"
        config.build_settings['OTHER_LDFLAGS'] = "#{config.build_settings['OTHER_LDFLAGS']} -framework FirebaseDatabase"
      end
    end
  end
end

