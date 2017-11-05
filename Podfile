
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/socketio/socket.io-client-swift'
source 'https://github.com/yahoojapan/SwiftyXMLParser.git'
platform :ios, ‘9.0’
use_frameworks!
target “UnTaxi” do
    pod 'Socket.IO-Client-Swift', '~> 11.1.3'
    pod 'Canvas'
    pod 'AFNetworking'
    pod 'SwiftyJSON'
    pod 'SwiftyXMLParser'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
    
end
