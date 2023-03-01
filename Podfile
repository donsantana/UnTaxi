source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target "UnTaxi" do
    pod 'Socket.IO-Client-Swift'
    pod 'Canvas'
    pod 'AFNetworking'
    pod 'SwiftyJSON'
    pod 'MaterialComponents/TextFields'
    pod 'TextFieldEffects'
    pod 'GooglePlaces'
    pod 'R.swift'
		pod 'MapboxMaps', '10.9.0'
		pod 'MapboxSearch', ">= 1.0.0-beta.38", "< 2.0"
		pod 'MapboxSearchUI', ">= 1.0.0-beta.38", "< 2.0"
    pod 'MapboxGeocoder.swift'
    pod 'MapboxDirections'
    pod 'CurrencyTextField'
    pod 'PhoneNumberKit', '~> 3.3'
    pod 'FloatingPanel'
    pod 'SideMenu'
    pod 'CountryPickerSwift'
		pod 'ToastViewSwift'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
 end
end
