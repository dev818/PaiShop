# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'paishop' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for paishop
  pod 'BaiduMapKit', '3.4.4'
  pod 'SDCycleScrollView'
  pod 'MJRefresh'
  pod 'IQKeyboardManagerSwift'
  pod 'Toast-Swift'
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'ObjectMapper'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  pod 'AssistantKit'
  pod 'ESTabBarController-swift'
  pod 'TimedSilver'
  pod 'SVProgressHUD'
  pod 'Kingfisher'
  pod 'YYText'
  pod 'KeychainAccess'
  pod 'UITextView+Placeholder'
  pod 'BEMCheckBox'
  pod 'DLRadioButton'
  pod 'BSImagePicker'
  pod 'DropDown'
  pod 'DatePickerDialog'
  pod 'SKPhotoBrowser'
  pod 'QRCodeReader.swift'
  pod 'IGRPhotoTweaks'
  pod 'swiftScan'
  pod 'MonkeyKing'
  pod 'XLActionController'
  #pod 'XLActionController/Tweetbot'
  pod 'XLActionController/Periscope'
  pod 'AliyunOSSiOS'
  pod 'AlivcLivePusherWithPlayer', '3.2.0'
  pod 'AliyunPlayer_iOS', '3.4.0.1'
  pod 'Starscream'
  pod 'XLPagerTabStrip'
  pod 'SDWebImage/WebP'
  pod 'QRCode'
  
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
