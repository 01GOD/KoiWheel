#
# Be sure to run `pod lib lint KoiWheel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KoiWheel'
  s.version          = '0.1.0'
  s.summary          = 'A customizable subclass of UIControl which allows you to create a Jog Wheel, Turntable or Knob.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A customizable subclass of UIControl which allows you to create a Jog Wheel, Turntable or Knob.
Developers can adjust the Angular Resistance of the wheel to customize its feel.
                       DESC

  s.homepage         = 'https://github.com/kwabford/KoiWheel'
  s.screenshots     = 'https://raw.githubusercontent.com/kwabford/KoiWheel/master/Media/screenshot1.png', 'https://raw.githubusercontent.com/kwabford/KoiWheel/master/Media/screenshot2.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kwabford' => 'kwabford@gmail.com' }
  s.source           = { :git => 'https://github.com/kwabford/KoiWheel.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kwabford'

  s.ios.deployment_target = '12.0'

  s.source_files = 'KoiWheel/Classes/**/*'
  
  s.swift_version = '4.2'
  
  # s.resource_bundles = {
  #   'KoiWheel' => ['KoiWheel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
