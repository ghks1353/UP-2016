platform :ios, '8.1'
use_frameworks!

target "UP" do
	pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"
	pod 'SwiftyJSON', :git => "https://github.com/appsailor/SwiftyJSON.git", :branch => "swift3"
	pod 'Gifu'
	pod 'Charts'
    pod 'SQLite.swift'
    pod 'SwiftyStoreKit'
    pod 'Firebase'
	pod 'GoogleIDFASupport'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
