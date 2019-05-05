

import UIKit
import DropDown
import DatePickerDialog
import MobileCoreServices
import Photos
import BEMCheckBox

class MyStoreProductPostVC: UIViewController {
    
    var isEdit = false
    var productItem: ProductListModel!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var storeSelectLabel: UILabel!
    @IBOutlet weak var categorySelectView: UIStackView!
    @IBOutlet weak var categoryAnchorView: UIView!    
    @IBOutlet weak var categorySelectLabel: UILabel!
    @IBOutlet weak var productNameField: UITextField!    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceField: UITextField! {
        didSet {
            priceField.delegate = self
        }
    }
    @IBOutlet weak var paiCheckBox: BEMCheckBox!
    @IBOutlet weak var cnyCheckBox: BEMCheckBox!
    
    @IBOutlet weak var inventoryField: UITextField!
    @IBOutlet weak var treasureRatioLabel: UILabel!
    @IBOutlet weak var treasureRatioSlider: UISlider!
    @IBOutlet weak var sliderMinusView: RoundRectButton! {
        didSet {
            sliderMinusView.imageView?.setTintColor(UIColor.white)
        }
    }
    @IBOutlet weak var sliderPlusView: RoundRectButton! {
        didSet {
            sliderPlusView.imageView?.setTintColor(UIColor.white)
        }
    }    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(MyStoreProductPostCell.self)
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
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postButtonBg: GradientView!
    
    @IBOutlet weak var treasureGroupFrame: UIView!
    @IBOutlet weak var treasureGroupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnPeriodLabel: UILabel!
    @IBOutlet weak var sellerReturnLabel: UILabel!
    @IBOutlet weak var buyerReturnLabel: UILabel!
    @IBOutlet weak var QRCodeView: UIStackView!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var QRCodeFrame: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    
    var categories: [CategoryModel] = []
    var stores: [StoreDetailModel] = []
    //var categories: [CategoryModel] = []
    var storeDropDown: DropDown!
    var selectedStoreId: Int64!
    var categoryDropDown: DropDown!    
    var selectedCategoryId: Int64!
    var customImageArray: [CustomImageModel] = []
    var deletedImages: [String] = []
    var checkBoxGroup: BEMCheckBoxGroup!
    var customQRCodeImage: CustomImageModel!
    
    var imageSheetTitle: String = ""
    var selectedImageSheet: Int = 1 // 1 - QRCode, 2 - images
    var productName: String = ""
    var productDescription: String = ""
    var productPrice: String = ""
    var productAmount: String = ""
    var restitutionRate: Double = 200
    var currencyRate: Double = 0.0
    
    var editingSuccess = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.getData()
        self.loadCategories()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "发布商品"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @objc private func showCategoryView() {
        if categoryDropDown != nil {
            self.categoryDropDown.show()
        } else {
            ProgressHUD.showWarningWithStatus("无法获得类别!")
        }
    }
    
    private func setupTheme() {
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(showCategoryView))
        categorySelectView.isUserInteractionEnabled = true
        categorySelectView.addGestureRecognizer(categoryTap)
        
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        
        storeSelectLabel.textColor = MainColors.themeEndColors[selectedTheme]
        categorySelectLabel.textColor = MainColors.themeEndColors[selectedTheme]
        productNameField.textColor = MainColors.themeEndColors[selectedTheme]
        descriptionTextView.textColor = MainColors.themeEndColors[selectedTheme]
        priceField.textColor = MainColors.themeEndColors[selectedTheme]
        inventoryField.textColor = MainColors.themeEndColors[selectedTheme]
        sliderMinusView.backgroundColor = MainColors.themeEndColors[selectedTheme]
        sliderPlusView.backgroundColor = MainColors.themeEndColors[selectedTheme]
        treasureRatioSlider.minimumTrackTintColor = MainColors.themeEndColors[selectedTheme]
        treasureRatioLabel.textColor = MainColors.themeEndColors[selectedTheme]
        returnPeriodLabel.textColor = MainColors.themeEndColors[selectedTheme]
        sellerReturnLabel.textColor = MainColors.themeEndColors[selectedTheme]
        buyerReturnLabel.textColor = MainColors.themeEndColors[selectedTheme]
//        cameraImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        
        postButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        postButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.restitutionRate != nil {
            self.restitutionRate = appDelegate.restitutionRate
        } else {
            self.restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        let sliderMinusTap = UITapGestureRecognizer(target: self, action: #selector(selectSliderMinus))
        sliderMinusView.isUserInteractionEnabled = true
        sliderMinusView.addGestureRecognizer(sliderMinusTap)
        
        let sliderPlusTap = UITapGestureRecognizer(target: self, action: #selector(selectSliderPlus))
        sliderPlusView.isUserInteractionEnabled = true
        sliderPlusView.addGestureRecognizer(sliderPlusTap)
        
//        let QRCodeTap = UITapGestureRecognizer(target: self, action: #selector(selectQRCodeView))
//        QRCodeView.isUserInteractionEnabled = true
//        QRCodeView.addGestureRecognizer(QRCodeTap)
        
        descriptionTextView.placeholder = "请输入商品详情"
        
        treasureRatioLabel.text = String(Int(treasureRatioSlider.value))
        checkBoxGroup = BEMCheckBoxGroup(checkBoxes: [paiCheckBox, cnyCheckBox])
        checkBoxGroup.mustHaveSelection = true
        checkBoxGroup.selectedCheckBox = paiCheckBox
        paiCheckBox.delegate = self
        cnyCheckBox.delegate = self
        
        self.setPaiValueLabels(49)
        
        if isEdit {
            storeSelectLabel.text = productItem.store?.name
            categorySelectLabel.text = productItem.category?.name
            productNameField.text = productName
            descriptionTextView.text = productDescription
            priceField.text = productPrice
            inventoryField.text = productAmount
            
            if productItem.qrimage! != "" {
                customQRCodeImage = CustomImageModel.init(imageURL: productItem.qrimage, image: nil, isImage: false)
                _ = Utils.getResizedImageUrlString(productItem.qrimage!, width: "800")
//                self.QRCodeImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: nil)
            }
            
            treasureRatioSlider.setValue(Float(productItem.treasureRatio!), animated: true)
            treasureRatioLabel.text = String(productItem.treasureRatio!)
            
            var treasure = Int(productItem.treasureRatio!)
            if treasure < 1 {
                treasure = 1
                treasureRatioLabel.text = "1"
            }
            setPaiValueLabels(treasure - 1)
            
            if productItem.paymentType! == 1 {
                checkBoxGroup.selectedCheckBox = paiCheckBox
                self.showTreasureGroup(true)
            } else if productItem.paymentType! == 2 {
                checkBoxGroup.selectedCheckBox = cnyCheckBox
                self.showTreasureGroup(false)
            }
            
            navBar.lblTitle.text = "变更商品"
            postButton.setTitle("变更商品", for: .normal)
            self.updateTableViewHeight()
        }
        
//        if UserInstance.degreeId! < 1 {
//            QRCodeFrame.isHidden = true
//            QRCodeFrame.snp.makeConstraints { (make) in
//                make.height.equalTo(0)
//            }
//        } else {
//            QRCodeFrame.isHidden = false
//        }
        
    }
    
    private func getData() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        ProgressHUD.showWithStatus()
        self.scrollView.isHidden = true
        MyAPI.shared.storeMine { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.scrollView.isHidden = false
                print("Store Mine...")
                print(json)
                self.setupUI()
                self.stores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                self.storeSelectLabel.text = self.stores.first?.name
                self.categorySelectLabel.text = self.stores.first?.category?.name
                self.selectedCategoryId = self.stores.first?.category?.id!
                self.selectedStoreId = self.stores.first?.storeId!
            } else {
                // try again...
                MyAPI.shared.storeMine(completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.scrollView.isHidden = false
                        self.setupUI()
                        self.stores = StoreDetailModel.getStoreDetailsFromJson(json["store"])
                        self.storeSelectLabel.text = self.stores.first?.name
                        self.selectedStoreId = self.stores.first?.storeId!
                        self.categorySelectLabel.text = self.stores.first?.category?.name
                        self.selectedCategoryId = self.stores.first?.category?.id!
                    } else {
                        ProgressHUD.showErrorWithStatus("无法获取商店的详细信息. 再试一次.")
                    }
                })
            }
        }
        
    }
    
    
    @IBAction func selectImagesAdd(_ sender: Any) {
        self.imageSheetTitle = "商品图片"
        self.selectedImageSheet = 2
        self.presentImageSheet()
    }
    
    func postProductImageArray() {
        var imageNames = [String](repeatElement("", count: self.customImageArray.count))
        var objectKeys = [String]()
        var images = [UIImage]()
        
        var qrcodeImageName = ""
        
        var uploadedCount = 0 // -> 2
        
        self.postButton.isEnabled = false
        if self.customQRCodeImage != nil {
            if self.customQRCodeImage.isImage {
                let width = Int(customQRCodeImage.image!.size.width)
                let height = Int(customQRCodeImage.image!.size.height)
                let sufix = "qrcode_\(width)x\(height).jpg"
                let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
                let objectKey = Constants.GOODS_IMAGE + "/\(self.selectedStoreId!)/" + "\(timestamp)" + sufix
                qrcodeImageName = Constants.ALIYUN_URL_PREFIX + objectKey
                //upload qrcode image...
                AliyunUtil.shared.putImage(customQRCodeImage.image!, objectKey: objectKey) { (result) in
                    uploadedCount += 1
                    self.postButton.isEnabled = true
                    if !result {
                        //qrcode image upload error
                        ProgressHUD.showErrorWithStatus("二维码上传错误")
                        return
                    }
                    if uploadedCount >= 2 {
                        // call product post or update api
                        self.productPost(imageNames: imageNames, qrcodeImageName: qrcodeImageName)
                    }
                }
            } else {
                qrcodeImageName = self.customQRCodeImage.imageURL!
                uploadedCount += 1
            }
        } else {
            uploadedCount += 1
        }
        
        for i in 0..<customImageArray.count {
            let customImage = customImageArray[i]
            if customImage.isImage {
                let width = Int(customImage.image!.size.width)
                let height = Int(customImage.image!.size.height)
                let sufix = "_\(width)x\(height).jpg"
                let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
                
                let objectKey = Constants.GOODS_IMAGE + "/\(self.selectedStoreId!)/" + "\(timestamp)" + sufix
                
                imageNames[i] = Constants.ALIYUN_URL_PREFIX + objectKey
                
                objectKeys.append(objectKey)
                images.append(customImage.image!)
            } else {
                imageNames[i] = customImage.imageURL!
            }
        }
        
        if objectKeys.count > 0 {
            AliyunUtil.shared.putImages(images, objectKeys: objectKeys, imageUrls: [String](), isImages: [Bool]()) { (results) in
                for i in 0..<results.count {
                    if !results[i] {
                        let objectKey = objectKeys[i]
                        let imageName = Constants.ALIYUN_URL_PREFIX + objectKey
                        let index = imageNames.index(of: imageName)
                        if let position = index {
                            imageNames.remove(at: position)
                        }
                    }
                }
                
                uploadedCount += 1
                self.postButton.isEnabled = true
                if imageNames.count < 3 {
                    // images upload error
                    ProgressHUD.showErrorWithStatus("商品图片上传错误")
                    return
                }
                
                if uploadedCount >= 2 {
                    // call product post or update api
                    self.productPost(imageNames: imageNames, qrcodeImageName: qrcodeImageName)
                }
            }
        } else {
            uploadedCount += 1
            if uploadedCount >= 2 {
                // call product post or update api
                self.postButton.isEnabled = true
                self.productPost(imageNames: imageNames, qrcodeImageName: qrcodeImageName)
            }
        }
    }
    
    func deleteImagesFromAliyun() {
        if self.deletedImages.count > 0 {
            let objectKeys = Utils.getObjectKeysFromImageUrls(self.deletedImages)
            AliyunUtil.shared.deleteImages(objectKeys) { (results) in }
        }
        
        if isEdit && productItem.qrimage! != "" && customQRCodeImage.isImage {
            let objectKey = Utils.getObjectKeyFromImageUrl(productItem.qrimage!)
            AliyunUtil.shared.deleteImage(objectKey) { (result) in }
        }
        
    }
    
    private func productPost(imageNames: [String], qrcodeImageName: String) {
        DispatchQueue.main.async {
            self.productName = self.productNameField.text!
            self.productDescription = self.descriptionTextView.text!
            self.productPrice = self.priceField.text!
            self.productAmount = self.inventoryField.text!
            
            var paymentType = 1
            if self.paiCheckBox.on && self.cnyCheckBox.on {
                paymentType = 3
            } else if self.paiCheckBox.on {
                paymentType = 1
            } else if self.cnyCheckBox.on {
                paymentType = 2
            }
            
            let product_images = "[\"" + (imageNames.map{$0}).joined(separator: "\", \"") + "\"]"
            
            var parameters: [String : Any] = [
                "category" : String(self.selectedCategoryId),
                "name" : self.productName,
                "description" : self.productDescription,
                "store" : String(self.selectedStoreId),
                "price" : self.productPrice,
                "amount" : self.productAmount,
                "currency" : String(paymentType),
                "images" : product_images
            ]
            
            if paymentType == 1 {
                parameters["profit_ratio"] = self.treasureRatioLabel.text!
            }
            
            if self.customQRCodeImage != nil {
                //add qrcode image name here
                parameters["qrimage"] = qrcodeImageName
            }
            
            print("Parameters...", parameters)
            self.postButton.isEnabled = false
            ProgressHUD.showWithStatus()
            
            if self.isEdit {
                parameters["id"] = String(self.productItem.id!)
                //if success, process deleted images
                MyAPI.shared.itemChange(params: parameters, completion: { (json, success) in
                    ProgressHUD.dismiss()
                    if success {
                        ProgressHUD.showSuccessWithStatus("成功改变了")
                        self.deleteImagesFromAliyun()
                        self.editingSuccess = true
                        let info: [String : Any] = ["success" : self.editingSuccess]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_ITEM_EDIT), object: nil, userInfo: info)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        self.postButton.isEnabled = true
                        let errors = json["errors"].dictionaryValue
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
                
            } else {
                MyAPI.shared.itemRegister(params: parameters, completion: { (json, success) in
                    ProgressHUD.dismiss()
                    if success {
                        ProgressHUD.showSuccessWithStatus("成功添加新商品")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        self.postButton.isEnabled = true
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("失败添加新商品.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败添加新商品.")
                        }
                    }
                })
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
        self.postProductImageArray()

    }
    
    
    @IBAction func treasureSliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        treasureRatioLabel.text = String(value)
        
        setPaiValueLabels(value - 1)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @objc func selectSliderMinus() {
        Utils.applyTouchEffect(sliderMinusView)
        let sliderValue = treasureRatioSlider.value
        if sliderValue > 1 {
            treasureRatioSlider.setValue(treasureRatioSlider.value - 1, animated: true)
            treasureRatioLabel.text = String(Int(treasureRatioSlider.value))
            setPaiValueLabels(Int(treasureRatioSlider.value) - 1)
        }
    }
    
    @objc func selectSliderPlus() {
        Utils.applyTouchEffect(sliderPlusView)
        let sliderValue = treasureRatioSlider.value
        if sliderValue < 100 {
            treasureRatioSlider.setValue(treasureRatioSlider.value + 1, animated: true)
            treasureRatioLabel.text = String(Int(treasureRatioSlider.value))
            setPaiValueLabels(Int(treasureRatioSlider.value) - 1)
        }
    }
    
    @objc func selectQRCodeView() {
//        Utils.applyTouchEffect(QRCodeView)
//        self.imageSheetTitle = "二维码"
//        self.selectedImageSheet = 1
//        self.presentImageSheet()
    }
    
    private func presentImageSheet() {
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
        
        if UserInstance.hasVerifiedStore() {
            if (self.customImageArray.count > 5) && (selectedImageSheet == 2) {
                ProgressHUD.showWarningWithStatus("你可以添加最多6张.")
            } else {
                self.present(sheet, animated: true, completion: nil)
            }
        } else {
            if (self.customImageArray.count > 2) && (selectedImageSheet == 2) {
                ProgressHUD.showWarningWithStatus("你可以添加最多3张.")
            } else {
                self.present(sheet, animated: true, completion: nil)
            }
        }
    }
    
    private func selectLibrary() {
        var maxNumber = 1
        if selectedImageSheet == 2 {
            if UserInstance.hasVerifiedStore() {
                maxNumber = 6 - self.customImageArray.count
            } else {
                maxNumber = 3 - self.customImageArray.count
            }
        }
        
        self.presentImagePickerController(
            maxNumberOfSelections: maxNumber,
            select: { (asset: PHAsset) -> Void in
                print("MyStoreProductPostVC Selected: \(asset)")
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
                        self?.customQRCodeImage = customImage
                    } else if self?.selectedImageSheet == 2 {
                        self?.customImageArray.append(customImage)
                    }
                    
                }
            }
            DispatchQueue.main.async {
                if self?.selectedImageSheet == 1 {
//                    self?.QRCodeImageView.image = self?.customQRCodeImage.image
                } else if self?.selectedImageSheet == 2 {
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
        let productName = productNameField.text
        let productDescription = descriptionTextView.text
        let productPrice = priceField.text
        let productAmount = inventoryField.text
        let paiCheck = paiCheckBox.on
        let cnyCheck = cnyCheckBox.on
        
        if selectedStoreId == nil {
            ProgressHUD.showWarningWithStatus("无法获取您的商店详情.")
            return false
        }
        
        if selectedCategoryId == nil {
            ProgressHUD.showWarningWithStatus("请选择商品类型.")
            return false
        }
        
        guard let name = productName else {
            ProgressHUD.showWarningWithStatus("请输入商品标题.")
            return false
        }
        if name.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入商品标题.")
            return false
        }
        
        guard let description = productDescription else {
            ProgressHUD.showWarningWithStatus("请输入商品详情.")
            return false
        }
        if description.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入商品详情.")
            return false
        }
        
        guard let price = productPrice else {
            ProgressHUD.showWarningWithStatus("请输入门市价.")
            return false
        }
        if price.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入门市价.")
            return false
        }
        
        guard let amount  = productAmount else {
            ProgressHUD.showWarningWithStatus("请输入商品库存.")
            return false
        }
        if amount.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入商品库存.")
            return false
        }
        
        if !cnyCheck && !paiCheck {
            ProgressHUD.showWarningWithStatus("请选择付款方式.")
            return false
        }
        
        if customImageArray.count < 3 {
            ProgressHUD.showWarningWithStatus("请选择3张以上的商品图片.")
            return false
        }
        
        return true
    }
    
    private func resetFields() {
        selectedStoreId = nil
        storeSelectLabel.text = "请选择归属店铺"
        selectedCategoryId = nil
        categorySelectLabel.text = "请选择商品类型"
        productNameField.text = ""
        descriptionTextView.text = ""
        priceField.text = ""
        inventoryField.text = ""
        customImageArray = []
        updateTableViewHeight()
    }
    
    private func setPaiValueLabels(_ index: Int) {
        var newIndex = index
        if index > 99 {
            newIndex = 99
        } else if index < 0 {
            newIndex = 0
        }
        
        var restitutionRate: Double = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.periodRatio != nil {
            restitutionRate = appDelegate.restitutionRate
        } else {
            restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        if appDelegate.currencyRate != nil {
            self.currencyRate = appDelegate.currencyRate
        } else {
            self.currencyRate = UserDefaultsUtil.shared.getCurrencyRate()
        }
        let periodDouble = Double(PAISHOP_PERIODS_TABLE[newIndex])! * 135 / restitutionRate
        let roundedPeriod = round(periodDouble)
        let period = Int(roundedPeriod)
        returnPeriodLabel.text = "\(period)"
        
        let priceString = priceField.text!
        var price = 0.0
        if !priceString.isEmpty {
            if let tempPrice = Double(priceString) {
                price = tempPrice
            }
        }
        
        let piPrice = price / currencyRate
        
        let serverReturn = piPrice * self.restitutionRate * Double(index + 1) / (10000.0 * Double(period))
        let buyerReturn = piPrice / Double(period)
        
        sellerReturnLabel.text = String.init(format: "%.2f", serverReturn)
        buyerReturnLabel.text = String.init(format: "%.2f", buyerReturn)
    }
    
    private func showTreasureGroup(_ show: Bool) {
        if show {
            treasureGroupFrame.isHidden = false
            treasureGroupHeightConstraint.constant = 200
        } else {
            treasureGroupFrame.isHidden = true
            treasureGroupHeightConstraint.constant = 0
        }
    }

}



extension MyStoreProductPostVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                if self.selectedImageSheet == 1 {
                    self.customQRCodeImage = customImage
//                    self.QRCodeImageView.image = image
                } else if self.selectedImageSheet == 2 {
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



extension MyStoreProductPostVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customImageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyStoreProductPostCell = tableView.ts_dequeueReusableCell(MyStoreProductPostCell.self)
        //cell.setCellContent(self.imageArray[indexPath.row], index: indexPath.row, vc: self)
        cell.setCellContent(self.customImageArray[indexPath.row], index: indexPath.row, vc: self)
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




extension MyStoreProductPostVC: NavBarDelegate {
    func didSelectBack() {
        if self.isEdit {
            if editingSuccess {
                let info: [String : Any] = ["success" : editingSuccess]
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_ITEM_EDIT), object: nil, userInfo: info)
            }
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension MyStoreProductPostVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("End Editing...")
        
        let sliderValue = Int(treasureRatioLabel.text!)!
        self.setPaiValueLabels(sliderValue)
    }
}


extension MyStoreProductPostVC: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        if paiCheckBox.on {
            showTreasureGroup(true)
        } else if cnyCheckBox.on {
            showTreasureGroup(false)
        }
    }
}














