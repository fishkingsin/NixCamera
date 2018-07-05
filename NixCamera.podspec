#
# Be sure to run `pod lib lint NixCamera.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NixCamera'
  s.version          = '0.1.6'
  s.summary          = 'Simple Fast camera inspire by LLSimpleCamera'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Nixplay Simple Fast camera inspire by LLSimpleCamera, video and picture capture in the same screen ,add simple confirmation screen
                       DESC

  s.homepage         = 'https://github.com/fishkingsin/NixCamera'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'James Kong' => 'fishkingsin@gmail.com' }
  s.source           = { :git => 'https://github.com/fishkingsin/NixCamera.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.resource_bundles = {
      'NixCamera' => ['NixCamera/Assets/*.png', 'NixCamera/Assets/*.lproj']
  }
  s.ios.deployment_target = '8.0'

  s.source_files = 'NixCamera/Classes/**/*'

  # s.resource_bundles = {
  #   'NixCamera' => ['NixCamera/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'CircleProgressView'
  s.dependency 'Masonry'
  s.dependency 'RFRotate'
end
