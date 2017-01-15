#
#  Be sure to run `pod spec lint ZDMatrixPopover.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "ZDMatrixPopover"
  s.version      = "0.0.2"
  s.summary      = "Popover object to display small spread sheet data with title."

  s.description  = <<-DESC
	ZDMatrixPopover provide simple iterface to show small spread sheet like data in NSPopover.
	You can use delegate object to provide additional customization to standart properties.
	This object can be used in interface buildr by adding NSObject to Story Board or XIB and setting properties.
	repository include a test application as en example.
  DESC

  s.homepage     = "https://github.com/zdima/ZDMatrixPopover"
  s.screenshots  = "https://github.com/zdima/ZDMatrixPopover/raw/master/ScreenShot.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Dmitriy Zakharkin" => "mail@zdima.net" }
  s.platform     = :osx, "10.11"
  s.source       = { :git => "https://github.com/zdima/ZDMatrixPopover.git", :tag => "#{s.version}" }

  s.source_files = "src/*.{swift}"
  s.resource  = "src/*.xib"
  s.dependency 'SwiftLint', '~>0.15'

end
