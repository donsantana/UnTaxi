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
    pod 'Google-Mobile-Ads-SDK'
    pod 'GooglePlaces'
    pod 'R.swift'
    pod 'Mapbox-iOS-SDK'
    pod 'MapboxSearch', ">= 1.0.0-beta"
    pod 'MapboxSearchUI', ">= 1.0.0-beta"
    pod 'MapboxGeocoder.swift'
    pod 'MapboxDirections', '~> 0.33'
    pod 'CurrencyTextField'
    pod 'PhoneNumberKit', '~> 3.3'
    pod 'GoogleMaps', '4.0.0'
    pod 'FloatingPanel'
    pod 'SideMenu'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
 end
end
