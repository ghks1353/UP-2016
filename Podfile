source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.1'
use_frameworks!
target "UP" do
	pod 'CryptoSwift'
	pod 'Google'
	pod 'Google/Analytics'
	pod 'GoogleIDFASupport'
	pod 'SwiftyJSON', :git => 'https://github.com/appsailor/SwiftyJSON.git', :branch => 'swift3'
	pod 'Gifu'
	pod 'Charts/Realm'
    pod 'SQLite.swift', :git => 'https://github.com/stephencelis/SQLite.swift.git', :branch => 'swift3-mariotaku'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
