#
# Be sure to run `pod lib lint YGCVideoToolbox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YGCVideoToolbox'
  s.version          = '0.1.0'
  s.summary          = 'A toolbox to edit video.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      YGCVideoToolbox is a collection of video edit function.Help you resize video, trim video and make some fantsy effect.
                       DESC

  s.homepage         = 'https://github.com/zangqilong198812/YGCVideoToolbox'
  s.screenshots     = 'https://camo.githubusercontent.com/cfc03230e50baab26b79a1da7868182065e0a2c9/68747470733a2f2f7773312e73696e61696d672e636e2f6c617267652f303036744e633739677931666e706d676c3135726e6a33306a6730356b3075322e6a7067'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zangqilong' => 'zangqilong@gmail.com' }
  s.source           = { :git => 'https://github.com/zangqilong198812/YGCVideoToolbox.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'YGCVideoToolbox/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YGCVideoToolbox' => ['YGCVideoToolbox/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AVFoundation', 'Photos'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  # s.dependency 'AFNetworking', '~> 2.3'
end
