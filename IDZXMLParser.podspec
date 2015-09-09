Pod::Spec.new do |s|
  s.name         = "IDZXMLParser"
  s.version      = "0.1.2"
  s.summary      = "A class to parser XML."

  s.homepage     = "https://github.com/iosdevzone/IDZXMLParser"

  s.license      = "MIT"

  s.author             = { "iOS Developer Zone" => "idz@iosdeveloperzone.com" }
  s.social_media_url   = "http://twitter.com/iOSDevZone"

  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/iosdevzone/IDZXMLParser.git", :tag => s.version.to_s }

  s.source_files  = "IDZXMLParser"
  s.public_header_files = "IDZXMLParser/*.h"

  s.dependency "IDZDelegateLogger", "~>0.1.0"
  s.dependency "expat"

  s.library = 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
