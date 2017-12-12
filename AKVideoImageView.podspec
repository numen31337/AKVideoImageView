Pod::Spec.new do |s|
  s.name           = "AKVideoImageView"
  s.version        = "1.1.0"
  s.summary        = "UIImageView subclass to a looped video"
  s.description    = "UIImageView subclass which allows you to display a looped video and even dynamically switch it"
  s.homepage       = "https://github.com/numen31337/AKVideoImageView"
  s.screenshots    = "https://raw.githubusercontent.com/numen31337/AKVideoImageView/master/Resources/example.gif"
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.author         = { "Oleksandr Kirichenko" => "numen31337@gmail.com" }
  s.social_media_url      = "https://www.facebook.com/AleksandrKirichenko"
  s.ios.deployment_target = "7.1"
  s.tvos.deployment_target = "9.0"
  s.source        = { :git => "https://github.com/numen31337/AKVideoImageView.git", :tag => "#{s.version}" }
  s.source_files  = "Classes/*.{h,m}"
  s.frameworks = "UIKit", "AVFoundation"
  s.requires_arc  = true
end
