Pod::Spec.new do |s|
  s.name = "ScreamURITemplate"
  s.version = "2.0.1"
  s.summary = "Robust and performant Swift implementation of RFC6570 URI Template"
  s.homepage = "https://github.com/SwiftScream/URITemplate"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author = { "Alex Deem" => "alexdeem@gmail.com" }
  s.source = { :git => "https://github.com/SwiftScream/URITemplate.git", :tag => "#{s.version}" }
  s.source_files = "Source/*.swift", "Source/Internal/*.swift"
  s.swift_version = "4.1"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
end
