platform :ios, '8.1'
use_frameworks!

target "UP" do
	pod 'CryptoSwift'
	pod 'SwiftyJSON'
	pod 'Gifu'
	pod 'Charts'
    pod 'SQLite.swift'
    pod 'SwiftyStoreKit'
	
	pod 'pop'
	
    pod 'Firebase/Core'
	pod 'Firebase/Messaging'
	pod 'Firebase/Crash'
	pod 'Firebase/RemoteConfig'
	pod 'GoogleIDFASupport'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
