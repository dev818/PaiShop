

import UIKit
import IQKeyboardManagerSwift

class ApplicationManager: NSObject {
    
    static func appConfigInit(_ appDelegate: AppDelegate) {
        
        ProgressHUD.initHUD()
        
        setupBaiduMap(appDelegate)
        
        setupIQKeyboardManager()
        
    }
    
    static func setupBaiduMap(_ appDelegate: AppDelegate) {
        let baiduMapApiKey = "2RGqoPjEG4wchlkS2rXu5UEMmtkU9zSA"
        let _mapManager: BMKMapManager?
        
        // To use Baidu map, please start BaiduMapManager
        _mapManager = BMKMapManager()
        /**
         *Baidu map SDK all interfaces support Baidu coordinates (BD09) and the State Bureau coordinates (GCJ02), use this method to set the type of coordinates you use.
         *The default is BD09 (BMK_COORDTYPE_BD09LL) coordinates.
         *If you need to use GCJ02 coordinates, you need to set CoordinateType to: BMK_COORDTYPE_COMMON.
         */
        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORDTYPE_BD09LL) {
            NSLog("经纬度类型设置成功");
        } else {
            NSLog("经纬度类型设置失败");
        }
        // If you want to focus on the network and authorized to verify the incident, please set the generalDelegate parameters
        let ret = _mapManager?.start(baiduMapApiKey, generalDelegate: appDelegate)
        if ret == false {
            NSLog("manager start failed!")
        }
    }
    
    static func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChatVC.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(HomeProductDetailVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(HomeProductDetailVC.self)
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(TicketMessageVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(TicketMessageVC.self)
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(LiveVideoPlayerVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(LiveVideoPlayerVC.self)
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(LiveVideoPlayBackVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(LiveVideoPlayBackVC.self)
        
    }

}











