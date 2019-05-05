
typealias ImageAsset = UIImage.Asset

import Foundation

extension UIImage {
    enum Asset: String {
        case home_menu1 = "home_menu1.png"
        case home_menu2 = "home_menu2.png"
        case home_menu3 = "home_menu3.png"
        case home_menu4 = "home_menu4.png"
        case home_menu5 = "home_menu5.png"
        case home_menu6 = "home_menu6.png"
        case home_menu7 = "home_menu7.png"
        case home_menu8 = "home_menu8.png"
        case home_menu9 = "home_menu9.png"
        case home_menu10 = "home_menu10.png"
        case home_menu_bar1 = "home_menu_bar1.png"
        case home_menu_bar2 = "home_menu_bar2.png"
        case home_menu_bar3 = "home_menu_bar3.png"
        case home_menu_bar4 = "home_menu_bar4.png"
        case home_menu_bar5 = "home_menu_bar5.png"
        case home_menu_bar6 = "home_menu_bar6.png"
        case home_menu_bar7 = "home_menu_bar7.png"
        case home_menu_bar8 = "home_menu_bar8.png"
        case home_menu_bar9 = "home_menu_bar9.png"
        case home_menu_bar10 = "home_menu_bar10.png"
        
        
        case social_chat_share = "social_chat_share"
        case social_chat_send = "social_chat_send.png"
        case social_SenderTextNodeBkg = "social_SenderTextNodeBkg"
        case social_SenderTextNodeBkgHL = "social_SenderTextNodeBkgHL"
        case social_ReceiverTextNodeBkg = "social_ReceiverTextNodeBkg"
        case social_ReceiverTextNodeBkgHL = "social_ReceiverTextNodeBkgHL"
        case social_chat_group = "social_chat_group.png"
        case social_SenderImageNodeMask = "social_SenderImageNodeMask"
        case social_SenderImageNodeBorder = "social_SenderImageNodeBorder"
        case social_ReceiverImageNodeMask = "social_ReceiverImageNodeMask"
        case social_ReceiverImageNodeBorder = "social_ReceiverImageNodeBorder"
        case social_blur = "social_blur.jpg"
        case social_music_play = "social_music_play"
        case social_music_pause = "social_music_pause"
        
        
        case auth_eye = "auth_eye.png"
        case auth_eye_show = "auth_eye_show.png"
        
        
        case my_upgrade_bronze = "my_upgrade_bronze.png"
        case my_upgrade_silver = "my_upgrade_silver.png"
        case my_upgrade_gold = "my_upgrade_gold.png"
        case my_upgrade_supreme = "my_upgrade_supreme.png"
        case my_shopping_calc_plus = "my_shopping_calc_plus.png"
        case my_store_upload = "my_store_upload1.png"
        case my_store_download = "my_store_download1.png"
        case my_store_upload_black = "my_store_upload1_black.png"
        case my_store_download_black = "my_store_download1_black.png"
        case my_store_trash = "my_store_trash"
        case my_help_center_icon = "my_help_center_icon.png"
        
        
        case guide_to_map = "guide_to_map.png"
        case guide_to_list = "guide_to_list.png"
        case my_location_pin = "my_location_pin.png"
        
        case find_like_red = "find_like_red.png"
        case find_dislike = "find_dislike.png"
        
        case icon_avatar = "icon_avatar.png"
        case icon_store = "icon_store.png"
        case splash = "splash_0.jpg"
        case splash_1 = "splash_1.jpg"
        case splash_2 = "splash_2.jpg"
        case splash_3 = "splash_3.jpg"
        case default_image = "default_image.png"
        case app_icon_share = "app_icon_share.jpg"
        
        case payment_pai = "ic_my_pai_icon.png"
        case payment_point = "my_pay_point.png"
        case payment_weixin = "ic_my_weixin_icon.png"
        case payment_ali = "my_pay_alipay.png"
        
        case level0 = "my_recm_vip_icon.png"
        case level1 = "my_recm_level1.png"
        case level2 = "my_recm_level2.png"
        case level3 = "my_recm_level3.png"
        case level4 = "my_recm_level4.png"
        case level5 = "my_recm_level5.png"
        
        var image: UIImage {
            return UIImage(asset: self)
        }
    }
    
    convenience init(asset: Asset) {
        self.init(named: asset.rawValue)!
    }
}
