#
# Be sure to run `pod lib lint A1IOSLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name         = "A1IOSLib"
  spec.version      = "1.1.31"
  spec.summary      = "Private common A1IOSLib."
  spec.description  = "Private common SDK to personal use A1IOSLib."
  spec.homepage         = 'https://github.com/TusharSpiral/A1IOSLib'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { "TusharSpiral" => "97023392+TusharSpiral@users.noreply.github.com" }
  spec.source           = { :git => 'https://TusharSpiral@github.com/TusharSpiral/A1IOSLib.git', :tag => spec.version.to_s }
  spec.platform     = :ios, "14.0"
    spec.swift_version = '5.0'
  spec.static_framework = true
  spec.ios.deployment_target  = '14.0'
  spec.resources = ["A1IOSLib/**/*.{storyboard}", "A1IOSLib/**/*.{xib}"]
  spec.source_files = ["A1IOSLib/**/*.{swift}", "A1IOSLib/**/*.{strings}"]
  spec.dependency 'Alamofire', '5.9.0'
  spec.dependency 'FirebaseAnalytics', '10.25.0'
  spec.dependency 'Firebase', '10.25.0'
  spec.dependency 'FBSDKCoreKit'
  spec.dependency 'YandexMobileMetrica', '4.5.2'
  spec.dependency 'Beacon', '3.0.0'
  spec.dependency 'Google-Mobile-Ads-SDK', '11.1.0'
  spec.dependency 'FirebaseRemoteConfig', '10.25.0'
  spec.dependency 'SwiftyJSON', '5.0.1'
  spec.dependency 'ShimmerSwift', '2.1.1'
end
