#
# Be sure to run `pod lib lint ELSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ELSwift'
  s.version          = '2.0.0'
  s.summary          = 'ELSwift carries out the ECHONET Lite protocol.'

  s.description      = <<-DESC
ELSwift supports the ECHONET Lite protocol.
The protocol is for connecting and controlling home appliances.
This library is for iOS.
                       DESC

  s.homepage         = 'https://github.com/Hiroshi-Sugimura/ELSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hiroshi-Sugimura' => 'hiroshi.sugimura@gmail.com' }
  s.source           = { :git => 'https://github.com/Hiroshi-Sugimura/ELSwift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_versions = '5.0'
  s.source_files = 'ELSwift/Classes/**/*'

  # s.resource_bundles = {
  #   'ELSwift' => ['ELSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CocoaAsyncSocket', '~> 7.6.5'

end
