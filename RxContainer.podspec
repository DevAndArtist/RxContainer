#
#  Be sure to run `pod spec lint RxContainer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

Pod::Spec.new do |s|

  s.name         = "RxContainer"
  s.version      = "0.5.0"
  s.summary      = "RxContainer provides the missing part between `UINavigationController` and `UIViewController`."
  s.description  = <<-DESC
  This CocoaPod provides a custom implementation for a `ContainerViewController`. `ContainerViewController`
  provides a very clean API and removes all unnecessary pieces that a `UINavigationController` would have 
  added when driving the app flow without the `UINavigationBar`.
                   DESC

  s.homepage     = "https://github.com/DevAndArtist/RxContainer"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author           = { "Adrian Zubarev" => "adrian.zubarev@devandartist.com" }
  s.social_media_url = "https://twitter.com/DevAndArtist"

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/DevAndArtist/RxContainer.git", :tag => "#{s.version}" }

  s.source_files  = "Sources/*.swift"

  s.framework  = "UIKit"

  s.dependency "RxSwift", "~> 3.4"

end
