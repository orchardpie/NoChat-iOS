platform :ios, '7.0'

pod 'AFNetworking'
pod 'MBProgressHUD'

target 'UISpecs', exclusive: true do
    platform :ios, '6.0'
    pod 'AFNetworking'
    pod 'Cedar'
    pod 'MBProgressHUD'
    pod 'PivotalCoreKit', git: 'https://github.com/pivotal/PivotalCoreKit'
    pod 'PivotalCoreKit/UIKit/SpecHelper', git: 'https://github.com/pivotal/PivotalCoreKit'
end

target 'Specs', exclusive: true do
    platform :osx, '10.8'
    pod 'AFNetworking'
    pod 'Cedar'
end
