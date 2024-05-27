source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '16.0'
use_frameworks!

target "UnTaxi" do
    pod 'Socket.IO-Client-Swift'
    pod 'Canvas'
    pod 'SwiftyJSON'
    pod 'MaterialComponents/TextFields'
    pod 'TextFieldEffects'
    pod 'R.swift'
    pod 'CurrencyTextField'
    pod 'PhoneNumberKit', '~> 3.3'
    pod 'FloatingPanel'
    pod 'SideMenu'
    pod 'ToastViewSwift'
    pod 'Google-Mobile-Ads-SDK'
    
    target 'VipCar'
    target 'LlamadaFacil'
    target 'OrientExpress'
    target 'AndyTaxi'
    target 'RuedaCar'
    target 'TransporVIP'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  end
 end
end
