#
# Be sure to run `pod lib lint ZSRouteUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZSRouteUtil'
  s.version          = '0.0.6'
  s.summary          = '路由工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
路由工具类
1、URL路由
                       DESC

  s.homepage         = 'https://github.com/zhangsen093725/ZSRouteUtil'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangsen093725' => '376019018@qq.com' }
  s.source           = { :git => 'https://github.com/zhangsen093725/ZSRouteUtil.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version    = '5.0'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZSRouteUtil/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZSRouteUtil' => ['ZSRouteUtil/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
