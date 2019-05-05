

import UIKit
import DatePickerDialog
import Photos
import MobileCoreServices
import BEMCheckBox



class MyStoreStorePostVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameField: UITextField! {
        didSet {
            nameField.text = ""
        }
    }
    @IBOutlet weak var categoryView: UIStackView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var contactNameField: UITextField! {
        didSet {
            contactNameField.text = Utils.getNickName()
            //contactNameField.isEnabled = false
        }
    }
    @IBOutlet weak var contactPhoneField: UITextField! {
        didSet {
            contactPhoneField.text = UserInstance.loginName
            //contactPhoneField.isEnabled = false
        }
    }
    @IBOutlet weak var addressView: UIStackView!
    
    @IBOutlet weak var addressBorderLine: UIView!
    @IBOutlet weak var addressInputView: UIStackView! 
    @IBOutlet weak var addressInputHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.text = ""
        }
    }
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var aliAddressField: UITextField!
    
    @IBOutlet weak var startTimeView: UIStackView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeView: UIStackView!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.text = ""
        }
    }
    //@IBOutlet weak var doorView: UIStackView!
    @IBOutlet weak var doorImageView: UIImageView!
    //@IBOutlet weak var licenseView: UIStackView!
    @IBOutlet weak var licenseImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(MyStoreStorePostCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.isEditing = true
        }
    }
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeightConstraint.constant = 0
        }
    }
    
    @IBOutlet weak var postButton: RoundRectButton!
    @IBOutlet weak var postButtonBg: GradientView!
    
    
    @IBOutlet var storeTypeView: RoundRectView!
    @IBOutlet weak var storeTypeCollectionView: UICollectionView! {
        didSet {
            storeTypeCollectionView.ts_registerCellNib(MyStoreTypeCell.self)
        }
    }
    @IBOutlet weak var darkView: UIView!
    //@IBOutlet weak var cameraImageView1: UIImageView!
    //@IBOutlet weak var cameraImageView2: UIImageView!
    
    @IBOutlet weak var offlineOnCheckBox: BEMCheckBox!
    @IBOutlet weak var offlineOffCheckBox: BEMCheckBox!
    @IBOutlet weak var businessCheckBox: BEMCheckBox!
    @IBOutlet weak var privateCheckBox: BEMCheckBox!
    
    var onlineCheckGroup: BEMCheckBoxGroup!
    var businessCheckGroup: BEMCheckBoxGroup!
    
    var categories: [CategoryModel] = []
    var selectedCategoryId: Int64!    
    var startTime: Date!
    var endTime: Date!
    var imageSheetTitle: String = ""
    var selectedImageSheet: Int = 1 // 1 - door, 2 - license, 3 - images
    var customDoorImage: CustomImageModel!
    var customLicenseImage: CustomImageModel!
    var customImageArray: [CustomImageModel] = []
    var deletedImages: [String] = []
    
    var storeName: String = ""
    var contactName: String = ""
    var contactPhone: String = ""
    var storeDescription: String = ""
    var storeLat: String = ""
    var storeLng: String = ""
    var storeAddress: String = ""
    var storeCity: String = ""
    var aliAddress: String = ""
    
    var isEdit = false
    var storeDetail: StoreDetailModel!
    
    var selectedTheme = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupUI()
        self.setupCustomView()
        self.getData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAddress(_:)), name: NSNotification.Name(Notifications.SELECT_ADDRESS), object: nil)
        
        if UserInstance.hasStore() {
            navBar.lblTitle.text = "我的店铺"
            postButton.setTitle("店铺修改", for: .normal)
            
            HomeAPI.shared.storeDetail(storeId: Int64(UserInstance.storeId!), completion: { (json, success) in
                if success {
                    print("Store Detail...")
                    print(json)
                    self.isEdit = true
                    self.storeDetail = StoreDetailModel.init(json["store"])
                    self.setupStoreDetails()
                } else {
                    ProgressHUD.showErrorWithStatus("无法获得您的店铺细节.")
                    self.scrollView.isHidden = true
                }
            })
        }
        
    }
    
    private func setupStoreDetails() {
        storeName = storeDetail.name!
        nameField.text = storeName
        
        selectedCategoryId = storeDetail.category?.id!
        categoryLabel.text = storeDetail.category?.name
        
        self.addressInputHeightConstraint.constant = 83
        self.addressBorderLine.isHidden = false
        self.addressLabel.isHidden = false
        self.addressField.isHidden = false
        self.storeAddress = storeDetail.address!
        self.storeCity = storeDetail.city!.name!
        self.storeLat = String(storeDetail.lat!)
        self.storeLng = String(storeDetail.lng!)
        self.addressLabel.text = storeAddress
        self.aliAddress = storeDetail.alipayAddress!
        aliAddressField.text = self.aliAddress
        
        let opening = storeDetail.opening!
        let times = opening.split(separator: "~")
        self.startTimeLabel.text = times[0].description
        self.endTimeLabel.text = times[1].description
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.startTime = formatter.date(from: startTimeLabel.text!)
        self.endTime = formatter.date(from: endTimeLabel.text!)
        
        self.storeDescription = storeDetail.introduction!
        self.descriptionTextView.text = self.storeDescription
        
        self.customDoorImage = CustomImageModel.init(imageURL: storeDetail.image, image: nil, isImage: false)
        let resizedDoorUrl = Utils.getResizedImageUrlString(storeDetail.image!, width: "800")
        self.doorImageView.setImageWithURLStringNoCache(resizedDoorUrl, placeholderImage: nil)
        
        self.customLicenseImage = CustomImageModel.init(imageURL: storeDetail.license, image: nil, isImage: false)
        let resizedLicenseUrl = Utils.getResizedImageUrlString(storeDetail.license!, width: "800")
        self.licenseImageView.setImageWithURLStringNoCache(resizedLicenseUrl, placeholderImage: nil)
        if let images = storeDetail.images, images.count > 0 {
            for image in images {
                let customImage = CustomImageModel.init(imageURL: image, image: nil, isImage: false)
                self.customImageArray.append(customImage)
            }
            self.updateTableViewHeight()
        }
        
        if storeDetail.offline! {
            self.onlineCheckGroup.selectedCheckBox = offlineOnCheckBox
        } else {
            self.onlineCheckGroup.selectedCheckBox = offlineOffCheckBox
        }
        if storeDetail.business! {
            self.businessCheckGroup.selectedCheckBox = businessCheckBox
        } else {
            self.businessCheckGroup.selectedCheckBox = privateCheckBox
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "新店入驻"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupUI() {
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(selectCategoryView))
        categoryView.isUserInteractionEnabled = true
        categoryView.addGestureRecognizer(categoryTap)
        
        let startTimeTap = UITapGestureRecognizer(target: self, action: #selector(selectStartTimeView))
        startTimeView.isUserInteractionEnabled = true
        startTimeView.addGestureRecognizer(startTimeTap)
        
        let endTimeTap = UITapGestureRecognizer(target: self, action: #selector(selectEndTimeView))
        endTimeView.isUserInteractionEnabled = true
        endTimeView.addGestureRecognizer(endTimeTap)
        
        let doorTap = UITapGestureRecognizer(target: self, action: #selector(selectDoorView))
        doorImageView.isUserInteractionEnabled = true
        doorImageView.addGestureRecognizer(doorTap)
        
        let licenseTap = UITapGestureRecognizer(target: self, action: #selector(selectLicenseView))
        licenseImageView.isUserInteractionEnabled = true
        licenseImageView.addGestureRecognizer(licenseTap)
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(selectAddressView))
        addressView.isUserInteractionEnabled = true
        addressView.addGestureRecognizer(addressTap)
        
        let darkViewTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(darkViewTap)
        
        contactPhoneField.delegate = self
        descriptionTextView.placeholder = "请输入店铺介绍"
        
        addressInputHeightConstraint.constant = 0
        addressBorderLine.isHidden = true
        addressLabel.isHidden = true
        addressField.isHidden = true
        
        onlineCheckGroup = BEMCheckBoxGroup(checkBoxes: [offlineOnCheckBox, offlineOffCheckBox])
        onlineCheckGroup.mustHaveSelection = true
        
        businessCheckGroup = BEMCheckBoxGroup(checkBoxes: [businessCheckBox, privateCheckBox])
        businessCheckGroup.mustHaveSelection = true
        
    }
    
    private func setupTheme() {
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        nameField.textColor = MainColors.themeEndColors[selectedTheme]
        if selectedCategoryId != nil {
            categoryLabel.textColor = MainColors.themeEndColors[selectedTheme]
        }
        contactNameField.textColor = MainColors.themeEndColors[selectedTheme]
        contactPhoneField.textColor = MainColors.themeEndColors[selectedTheme]
        addressLabel.textColor = MainColors.themeEndColors[selectedTheme]
        addressField.textColor = MainColors.themeEndColors[selectedTheme]
        if self.startTime != nil {
            startTimeLabel.textColor = MainColors.themeEndColors[selectedTheme]
        }
        if self.endTime != nil {
            endTimeLabel.textColor = MainColors.themeEndColors[selectedTheme]
        }
        descriptionTextView.textColor = MainColors.themeEndColors[selectedTheme]
        
        postButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        postButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        
        offlineOnCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        offlineOnCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        offlineOffCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        offlineOffCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        businessCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        businessCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        privateCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        privateCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        
    }
    
    private func setupCustomView() {
        self.view.addSubview(storeTypeView)
        storeTypeView.translatesAutoresizingMaskIntoConstraints = false
        storeTypeView.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(250)
            make.centerX.equalTo(self.view.centerX)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
    }
    
    private func getData() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.categoryRoot { (json, success) in
            if success {
                self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                //self.setupCategoryDropDown()
                self.storeTypeCollectionView.reloadData()
            } else {
                // try again...
                HomeAPI.shared.categoryRoot(completion: { (json, success1) in
                    if success1 {
                        self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                        //self.setupCategoryDropDown()
                        self.storeTypeCollectionView.reloadData()
                    }
                })
            }
        }
    }
    
    func getSelectedCategoryIndex() -> Int {
        var selectedCategoryIndex = -1
        if self.selectedCategoryId == nil {
            return -1
        }
        for i in 0..<self.categories.count {
            if categories[i].id! == selectedCategoryId {
                selectedCategoryIndex = i
            }
        }
        return selectedCategoryIndex
    }

    @IBAction func selectImagesAdd(_ sender: UIButton) {
        self.imageSheetTitle = "店铺照片"
        self.selectedImageSheet = 3
        self.presentImageSheet()
    }
    
    func postStoreImageArray() {
        var imageNames = [String](repeatElement("", count: self.customImageArray.count))
        var objectKeys = [String]()
        var images = [UIImage]()
        
        var doorImageName = ""
        var licenseImageName = ""
        
        var uploadedCount = 0 // -> 3
        
        if self.customDoorImage.isImage {
            //let width = Int(customDoorImage.image!.size.width)
            //let height = Int(customDoorImage.image!.size.height)
            let sufix = ".jpg"
            //let timestamp = Int(Date().timeIntervalSince1970 * 1000000)
            let objectKey = Constants.SHOP_IMAGE + "/\(UserInstance.userId!)/" + "door" + sufix
            doorImageName = Constants.ALIYUN_URL_PREFIX + objectKey
            //upload door image...
            AliyunUtil.shared.putImage(customDoorImage.image!, objectKey: objectKey) { (result) in
                uploadedCount += 1
                if !result {
                    //door image upload error
                    ProgressHUD.showErrorWithStatus("门店照片上传错误")
                    return
                }
                if uploadedCount >= 3 {
                    //call store post or update api
                    self.storePost(imageNames: imageNames, doorImageName: doorImageName, licenseImageName: licenseImageName)
                }
            }
        } else {
            doorImageName = customDoorImage.imageURL!
            uploadedCount += 1
        }
        
        if self.customLicenseImage.isImage {
            //let width = Int(customLicenseImage.image!.size.width)
            //let height = Int(customLicenseImage.image!.size.height)
            let sufix = ".jpg"
            //let timestamp = Int(Date().timeIntervalSince1970 * 1000000)
            let objectKey = Constants.SHOP_IMAGE + "/\(UserInstance.userId!)/" + "license" + sufix
            licenseImageName = Constants.ALIYUN_URL_PREFIX + objectKey
            //upload license image...
            AliyunUtil.shared.putImage(customLicenseImage.image!, objectKey: objectKey) { (result) in
                uploadedCount += 1
                if !result {
                    //license image upload error
                    ProgressHUD.showErrorWithStatus("营业执照上传错误")
                    return
                }
                if uploadedCount >= 3 {
                    //call store post or update api
                    self.storePost(imageNames: imageNames, doorImageName: doorImageName, licenseImageName: licenseImageName)
                }
            }
        } else {
            licenseImageName = customLicenseImage.imageURL!
            uploadedCount += 1
        }
        
        for i in 0..<customImageArray.count {
            let customImage = customImageArray[i]
            if customImage.isImage {
                let width = Int(customImage.image!.size.width)
                let height = Int(customImage.image!.size.height)
                let sufix = "_\(width)x\(height).jpg"
                let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
                
                let objectKey = Constants.SHOP_IMAGE + "/\(UserInstance.userId!)/" + "\(timestamp)" + sufix
                
                imageNames[i] = Constants.ALIYUN_URL_PREFIX + objectKey
                
                objectKeys.append(objectKey)
                images.append(customImage.image!)
                
            } else {
                imageNames[i] = customImage.imageURL!
            }
        }
        
        if objectKeys.count > 0 {
            AliyunUtil.shared.putImages(images, objectKeys: objectKeys, imageUrls: [String](), isImages: [Bool]()) { (uploadResults) in
                for i in 0..<uploadResults.count {
                    if !uploadResults[i] {
                        let objectKey = objectKeys[i]
                        let imageName = Constants.ALIYUN_URL_PREFIX + objectKey
                        let index = imageNames.index(of: imageName)
                        if let position = index {
                            imageNames.remove(at: position)
                        }
                    }
                }
                //upload finished...
                
                uploadedCount += 1
                if uploadedCount >= 3 {
                    //call store post or update api
                    self.storePost(imageNames: imageNames, doorImageName: doorImageName, licenseImageName: licenseImageName)
                }
            }
        } else {
            print("No Uploading Images.............")
            print(imageNames)
            uploadedCount += 1
            if uploadedCount >= 3 {
                //call store post or update api
                self.storePost(imageNames: imageNames, doorImageName: doorImageName, licenseImageName: licenseImageName)
            }
        }
        
        //print(imageNames)
    }
    
    private func storePost(imageNames: [String], doorImageName: String, licenseImageName: String) {
        DispatchQueue.main.async {
            self.storeName = self.nameField.text!
            self.contactName = self.contactNameField.text!
            self.contactPhone = self.contactPhoneField.text!
            self.storeDescription = self.descriptionTextView.text!
            self.aliAddress = self.aliAddressField.text!
            if let additionalAddress = self.addressField.text {
                self.storeAddress += " " + additionalAddress
            }
            
            var offline = true
            if self.offlineOffCheckBox.on {
                offline = false
            }
            var business = true
            if self.privateCheckBox.on {
                business = false
            }
            
            var parameters: [String : Any] = [
                "name" : self.storeName,
                "category" : String(self.selectedCategoryId),
                "user_name" : self.contactName,
                "phone_number" : self.contactPhone,
                "address" : self.storeAddress,
                "city" : self.storeCity,
                "lat" : self.storeLat,
                "lng" : self.storeLng,
                "open_time" : self.startTimeLabel.text!,
                "close_time" : self.endTimeLabel.text!,
                "introduction" : self.storeDescription,
                "image" : doorImageName,
                "license" : licenseImageName,
                "offline" : offline,
                "business" : business,
                "alipay_address": self.aliAddress
            ]
            
            if imageNames.count > 0 {
                // add image names into parameter
                let store_images = "[\"" + (imageNames.map{$0}).joined(separator: "\", \"") + "\"]"
                parameters["images"] = store_images
            }
            print("Parameters...", parameters)
            
            self.postButton.isEnabled = false
            ProgressHUD.showWithStatus()
            
            if self.isEdit {
                // process deleted images after success
                parameters["id"] = String(self.storeDetail.storeId!)
                MyAPI.shared.storeChange(params: parameters) { (json, success) in
                    if success {
                        self.postButton.isEnabled = true
                        ProgressHUD.dismiss()
                        ProgressHUD.showSuccessWithStatus("成功改变了")
                        self.deleteImagesFromAliyun()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        // try again...
                        MyAPI.shared.storeChange(params: parameters, completion: { (json1, success1) in
                            self.postButton.isEnabled = true
                            ProgressHUD.dismiss()
                            if success1 {
                                ProgressHUD.showSuccessWithStatus("成功改变了")
                                self.deleteImagesFromAliyun()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                                    self.navigationController?.popViewController(animated: true)
                                })
                            } else {
                                let errors = json1["errors"].dictionaryValue
                                if let error = errors.values.first {
                                    if let firstError =  error.arrayObject?.first as? String {
                                        ProgressHUD.showErrorWithStatus(firstError)
                                    } else {
                                        ProgressHUD.showErrorWithStatus("失败改变.")
                                    }
                                } else {
                                    ProgressHUD.showErrorWithStatus("失败改变.")
                                }
                            }
                        })
                    }
                }
                
            } else {
                HomeAPI.shared.storeRegister(params: parameters, completion: { (json, success) in
                    self.postButton.isEnabled = true
                    ProgressHUD.dismiss()
                    if success {
                        ProgressHUD.showSuccessWithStatus("成功添加新店铺!")
                        UserInstance.storeId = json["store"].intValue
                        self.resetFields()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("失败添加新店铺.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("失败添加新店铺.")
                        }
                    }
                })
            }
        }
        
    }
    
    func deleteImagesFromAliyun() {
        if self.deletedImages.count > 0 {
            let objectKeys = Utils.getObjectKeysFromImageUrls(self.deletedImages)
            AliyunUtil.shared.deleteImages(objectKeys) { (results) in
                
            }
        }
    }
    
    @IBAction func selectPost(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if !validateFields() {
            return
        }
        self.postStoreImageArray()
    }
    
    @objc func selectCategoryView() {
        Utils.applyTouchEffect(categoryView)
        /*if categoryDropDown != nil {
            categoryDropDown.show()
        } else {
            ProgressHUD.showErrorWithStatus("不能得到商品类型.")
        }*/
        if self.categories.count > 0 {
            self.showStoreTypeView()
        } else {
            ProgressHUD.showErrorWithStatus("不能得到商品类型.")
        }
    }
    
    @objc func selectStartTimeView() {
        Utils.applyTouchEffect(startTimeView)
        
        var defaultDate = Date()
        if self.startTime != nil {
            defaultDate = self.startTime
        }
        DatePickerDialog().show("开始时间", doneButtonTitle: "确认", cancelButtonTitle: "取消", defaultDate: defaultDate, minimumDate: nil, maximumDate: nil, datePickerMode: .time) { (date) in
            if let dt = date {
                self.startTime = dt
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                self.startTimeLabel.text = formatter.string(from: dt)
                
                self.endTime = self.startTime
                self.endTimeLabel.text = "关闭时间"
                self.startTimeLabel.textColor = MainColors.themeEndColors[self.selectedTheme]
            }
        }
        
    }
    
    
    @objc func selectEndTimeView() {
        Utils.applyTouchEffect(endTimeView)
        
        var defaultDate = Date()
        if self.endTime != nil {
            defaultDate = self.endTime
        }
        var minimumDate: Date!
        if self.endTime != nil {
            minimumDate = self.endTime
        }
        if self.startTime == nil {
            minimumDate = nil
        }
        DatePickerDialog().show("关闭时间", doneButtonTitle: "确认", cancelButtonTitle: "取消", defaultDate: defaultDate, minimumDate: minimumDate, maximumDate: nil, datePickerMode: .time) { (date) in
            if let dt = date {
                self.endTime = dt
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                self.endTimeLabel.text = formatter.string(from: dt)
                self.endTimeLabel.textColor = MainColors.themeEndColors[self.selectedTheme]
            }
        }
        
    }
    
    @objc func selectDoorView() {
        Utils.applyTouchEffect(doorImageView)
        self.imageSheetTitle = "门店/门头照片"
        self.selectedImageSheet = 1
        self.presentImageSheet()
    }
    
    @objc func selectLicenseView() {
        Utils.applyTouchEffect(licenseImageView)
        self.imageSheetTitle = "手持证件" //"工商营业执照"
        self.selectedImageSheet = 2
        self.presentImageSheet()
    }
    
    @objc func selectAddressView() {
        Utils.applyTouchEffect(addressView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreAddressVC.nameOfClass) as! MyStoreAddressVC
        vc.senderVC = MyStoreStorePostVC.nameOfClass
        self.pushAndHideTabbar(vc)
    }
    
    @objc func receiveAddress(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyStoreStorePostVC.nameOfClass {
            return
        }
        if let address = notification.userInfo?["address"] as? BMKReverseGeoCodeResult {
            self.storeLat = String(address.location.latitude)
            self.storeLng = String(address.location.longitude)
            self.storeAddress = address.address
            self.storeCity = address.addressDetail.city
            
            print("MyStoreProductPost...")
            print("Lat...", storeLat)
            print("Lng...", storeLng)
            print("Address...", storeAddress)
            print("City...", storeCity)
            
            self.addressInputHeightConstraint.constant = 83
            self.addressBorderLine.isHidden = false
            self.addressLabel.isHidden = false
            self.addressLabel.text = self.storeAddress
            self.addressField.isHidden = false
        }
    }

        
    func presentImageSheet() {
        let sheet = UIAlertController(title: nil, message: imageSheetTitle, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectCamera()
        })
        let photoAction = UIAlertAction(title: "相册", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectLibrary()
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        if (self.customImageArray.count > 5) && (selectedImageSheet == 3) {
            ProgressHUD.showWarningWithStatus("你可以添加最多6张.")
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    private func selectLibrary() {
        var maxNumber = 1
        if selectedImageSheet == 3 {
            maxNumber = 6 - self.customImageArray.count
        }
        
        self.presentImagePickerController(
            maxNumberOfSelections: maxNumber,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
        }, finish: {[weak self] (assets: [PHAsset]) -> Void in
            print("Finish: \(assets[0])")
            for asset in assets {
                if let image = asset.getUIImage() {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    if self?.selectedImageSheet == 1 {
                        self?.customDoorImage = customImage
                    } else if self?.selectedImageSheet == 2 {
                        self?.customLicenseImage = customImage
                    } else if self?.selectedImageSheet == 3 {
                        self?.customImageArray.append(customImage)
                    }
                }
            }
            DispatchQueue.main.async {
                if self?.selectedImageSheet == 1 {
                    self?.doorImageView.image = self?.customDoorImage.image
                } else if self?.selectedImageSheet == 2 {
                    self?.licenseImageView.image = self?.customLicenseImage.image
                } else if self?.selectedImageSheet == 3 {
                    self?.updateTableViewHeight()
                }
            }
            
            }, completion: { () -> Void in
                print("completion")
        })
    }
    
    private func selectCamera() {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
                if !granted {
                    self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
                } else {
                    let imagePicker =  UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
        } else if authStatus == .restricted || authStatus == .denied {
            self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
        } else if authStatus == .authorized {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func updateTableViewHeight() {
        //let tableViewHeight = ((UIScreen.ts_width - 32.0 - 40.0) * 2 / 3 + 16.0) * CGFloat(self.customImageArray.count)
        var tableViewHeight: CGFloat = 0
        if self.customImageArray.count > 0 {
            tableViewHeight = CGFloat(getImageArrayHeight()) + CGFloat(customImageArray.count * 16)
        }
        
        self.tableViewHeightConstraint.constant = tableViewHeight
        self.tableView.ts_reloadData {
            self.tableViewHeightConstraint.constant = tableViewHeight
            self.tableView.reloadData()
        }
    }
    
    private func getImageArrayHeight() -> Int {
        var imageHeights: [Int] = []
        
        let imageWidth: Int = Int(UIScreen.ts_width) - 32 - 40
        for _ in 0..<customImageArray.count {
            let imageHeight = imageWidth * 2 / 3
            imageHeights.append(imageHeight)
        }
        
        for i in 0..<customImageArray.count {
            let customImage = customImageArray[i]
            if customImage.isImage {
                if let image = customImage.image {
                    let width = Int(image.size.width)
                    let height = Int(image.size.height)
                    if width > 0 && height > 0 {
                        imageHeights[i] = height * imageWidth / width
                    }
                }
            } else {
                if let imageUrl = customImage.imageURL {
                    var width: Int = 0
                    var height: Int = 0
                    
                    let imageInfos = imageUrl.split(separator: "_")
                    if imageInfos.count > 1 {
                        let sizeUrl1 = imageInfos.last!
                        let sizeUrls = sizeUrl1.split(separator: ".")
                        if sizeUrls.count > 1 {
                            let sizeUrl = sizeUrls.first!
                            if sizeUrl.contains("x") {
                                let sizes = sizeUrl.split(separator: "x")
                                if sizes.count == 2 {
                                    width = Int(sizes[0])!
                                    height = Int(sizes[1])!
                                }
                            }
                        }
                    }
                    
                    if width > 0 && height > 0 {
                        imageHeights[i] = height * imageWidth / width
                    }
                }
            }
        }
        
        var imageArrayHeight = 0
        for imageHeight in imageHeights {
            imageArrayHeight += imageHeight
        }
        
        return imageArrayHeight
    }
    
    private func validateFields() -> Bool {
        let name = nameField.text!
        //let contactName = contactNameField.text!
        //let contactPhone = contactPhoneField.text!
        let description = descriptionTextView.text!
        
        
        if name.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入门店名.")
            return false
        }
        if selectedCategoryId == nil {
            ProgressHUD.showWarningWithStatus("请选择商品类型.")
            return false
        }
        /*if contactName.isEmpty {
            ProgressHUD.showWarningWithStatus("输入联系人姓名.")
            return false
        }
        
        if !validatePhone(contactPhone)  { //contactPhone.count < 11
            ProgressHUD.showWarningWithStatus("请输入有效的手机号码.")
            return false
        }*/
        
        if startTime == nil {
            ProgressHUD.showWarningWithStatus("请选择开始时间.")
            return false
        }
        if endTime == nil {
            ProgressHUD.showWarningWithStatus("请选择关闭时间.")
            return false
        }
        if description.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入店铺介绍.")
            return false
        }
        if storeCity.isEmpty {
            ProgressHUD.showWarningWithStatus("地址定位中...")
            return false
        }
        if customDoorImage == nil {
            ProgressHUD.showWarningWithStatus("请选择门店/门头照片.")
            return false
        }
        if customLicenseImage == nil {
            ProgressHUD.showWarningWithStatus("请选择工商营业执照.")
            return false
        }
        return true
    }
    
    func validatePhone(_ phone: String) -> Bool {
        let regex = "^(1)[0-9]{10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isMatch = predicate.evaluate(with: phone)
        return isMatch
    }
    
    private func resetFields() {
        nameField.text = ""
        categoryLabel.text = "请选择商品类型"
        selectedCategoryId = nil
        //contactNameField.text = ""
        //contactPhoneField.text = ""
        startTime = nil
        startTimeLabel.text = "开始时间"
        endTime = nil
        endTimeLabel.text = "关闭时间"
        descriptionTextView.text = ""
        doorImageView.image = nil
        customDoorImage = nil
        licenseImageView.image = nil
        customLicenseImage = nil
        customImageArray = []
        updateTableViewHeight()
        
        storeAddress = ""
        storeCity = ""
        storeLat = ""
        storeLng = ""
        addressLabel.text = ""
        addressField.text = ""
    }
    
    
    @objc func selectDarkView() {
        self.hideStoreTypeView()
    }
    
    private func hideStoreTypeView() {
        storeTypeView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    private func showStoreTypeView() {
        storeTypeView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func showDarkView(_ state: Bool) {
        if state {
            self.darkView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.8
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { (finished) in
                self.darkView.isHidden = true
            })
        }
    }

}


extension MyStoreStorePostVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension MyStoreStorePostVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customImageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyStoreStorePostCell = tableView.ts_dequeueReusableCell(MyStoreStorePostCell.self)
        cell.setCellContent(customImageArray[indexPath.row], index: indexPath.row, vc: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveImage = self.customImageArray[sourceIndexPath.row]
        self.customImageArray.remove(at: sourceIndexPath.row)
        self.customImageArray.insert(moveImage, at: destinationIndexPath.row)
        
        self.tableView.ts_reloadData {  }
    }
    
}

extension MyStoreStorePostVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                if self.selectedImageSheet == 1 {
                    self.customDoorImage = customImage
                    self.doorImageView.image = image
                } else if self.selectedImageSheet == 2 {
                    self.customLicenseImage = customImage
                    self.licenseImageView.image = image
                } else if self.selectedImageSheet == 3 {
                    self.customImageArray.append(customImage)
                    self.updateTableViewHeight()
                }
                
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension MyStoreStorePostVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if textField == contactPhoneField {
            return newLength <= 11
        }
        return true
    }
}














