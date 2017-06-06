
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/socketio/socket.io-client-swift'
platform :ios, ‘9.0’
use_frameworks!
target “UnTaxi” do
    pod 'Socket.IO-Client-Swift', '~> 10.0.0'
    pod 'GoogleMaps'
    pod 'Canvas'
    pod 'AFNetworking'
    pod 'SwiftyJSON'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
    
end
