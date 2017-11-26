Pod::Spec.new do |s|
  s.name         = "LLImagePickerObjC"
  s.version      = "0.0.1"
  s.summary      = "A clone of UIImagePickerController with multiple selection and clip support."
  s.description  = <<-DESC
                    支持自定义裁剪比例、仿微信图片裁剪、支持多选的图片选择器。
                   DESC
  s.homepage     = "https://github.com/kevll/LLImagePickerObjC"
  s.license      = "MIT"
  s.author             = { "kevll" => "kevliule@gmail.com" }
  s.social_media_url   = "https://twitter.com/kevliule"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/kevll/LLImagePickerObjC.git", :tag => "#{s.version}" }
  s.source_files  = "LLImagePicker/*.{h,m}","LLImagePicker/LLPhotoBrowser/*.{h,m}"
  s.exclude_files = "LLImagePicker/LLAssetsPicker.h"
  s.resource_bundles = { "LLImagePicker" => "LLImagePicker/*.{xib}" }
  s.frameworks       = "Photos"
  s.requires_arc = true
  s.resources = "LLImagePicker/Resource/*.png"
  s.dependency "SDWebImage"
  s.dependency "DACircularProgress"
end
