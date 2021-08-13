Pod::Spec.new do |s|
  s.name           = "AKVideoImageView"
  s.version        = "1.1.4"
  s.summary        = "UIImageView subclass for displaying looped videos"
  s.description    = "UIImageView subclass that allows you to display a looped video and dynamically switch it"
  s.homepage       = "https://github.com/numen31337/AKVideoImageView"
  s.screenshots    = "https://raw.githubusercontent.com/numen31337/AKVideoImageView/master/Resources/example.gif"
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.author         = { "Oleksandr Kirichenko" => "akvideoimageview@ab.oleksandrkirichenko.com" }
  s.ios.deployment_target = "7.1"
  s.tvos.deployment_target = "9.0"
  s.source        = { :git => "https://github.com/numen31337/AKVideoImageView.git", :tag => "#{s.version}" }
  s.source_files  = "Classes/*.{h,m}"
  s.frameworks = "UIKit", "AVFoundation"
  s.requires_arc  = true
end
