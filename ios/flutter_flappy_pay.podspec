#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_flappy_pay.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_flappy_pay'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*'

  s.public_header_files = 'Classes/**/*.h','Frameworks/UMSPosPayOnly/include/*.h'

  s.dependency 'Flutter'

  s.dependency 'WechatOpenSDK'

  s.resource = 'Frameworks/AlipaySDK.bundle','Frameworks/PosPay_Resource.bundle','Frameworks/UMSSecKeyboardLibResource.bundle'

  s.vendored_frameworks = 'Frameworks/AlipaySDK.framework'

  s.vendored_library = 'Frameworks/libUMSPosPayOnly.a','Frameworks/libPaymentControl.a'

  s.libraries = 'z','c++','stdc++'

  s.frameworks = 'CFNetwork','CoreFoundation','CoreMotion','CoreTelephony','CoreText','Foundation',
  'SystemConfiguration','UIKit','CoreGraphics','WebKit'

  s.platform = :ios, '8.0'

  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
