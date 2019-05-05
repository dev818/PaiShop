//
//  MyStoreProductPostVC1.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/08.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import DropDown
import DatePickerDialog
import MobileCoreServices
import Photos
import BEMCheckBox

class MyStoreProductPostVC1: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate,
    NavBarDelegate,
    BEMCheckBoxDelegate,
    MyStorePorductMediaCollectionViewCellDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
{
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storeSelectLabel: UILabel!
    @IBOutlet weak var categorySelectLabel: UILabel!
    @IBOutlet weak var category2SelectLabel: UILabel!
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceField: UITextField! {
        didSet {
            priceField.delegate = self
        }
    }
//    @IBOutlet weak var paiCheckBox: BEMCheckBox!
//    @IBOutlet weak var cnyCheckBox: BEMCheckBox!
    
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
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postButtonBg: GradientView!
    
    @IBOutlet weak var returnPeriodLabel: UILabel!
    @IBOutlet weak var sellerReturnLabel: UILabel!
    @IBOutlet weak var buyerReturnLabel: UILabel!
    
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var tableList2: UITableView!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView3: UICollectionView!
    @IBOutlet weak var collectionView4: UICollectionView!
    @IBOutlet weak var collectionView5: UICollectionView!
    
    
    @IBOutlet weak var imgRadio01: UIImageView!
    @IBOutlet weak var imgRadio02: UIImageView!
    
    @IBOutlet weak var imgRadio11: UIImageView!
    @IBOutlet weak var imgRadio12: UIImageView!
    @IBOutlet weak var imgRadio13: UIImageView!
    
    @IBOutlet weak var btnPromotion0: UIButton!
    @IBOutlet weak var btnPromotion1: UIButton!
    @IBOutlet weak var btnPromotion2: UIButton!
    @IBOutlet weak var btnPromotion3: UIButton!
    @IBOutlet weak var btnPromotion4: UIButton!
    
    var customImageArray1: [CustomImageModel] = []
    var customImageArray2: [CustomImageModel] = []
    var customImageArray: [CustomImageModel] = []
    var customImageArray4: [CustomImageModel] = []
    var customImageArray5: [CustomImageModel] = []
    
    var selectedCollectionViewIndex: NSInteger = 0
    
    var categories: [CategoryModel] = []
    var stores: [StoreDetailModel] = []
    var storeDropDown: DropDown!
    var selectedStoreId: Int64!
    var categoryDropDown: DropDown!
    
    var deletedImages: [String] = []
    //    var checkBoxGroup: BEMCheckBoxGroup!
    var customQRCodeImage: CustomImageModel!
    
    var productName: String = ""
    var productDescription: String = ""
    var productPrice: String = ""
    var productAmount: String = ""
    var restitutionRate: Double = 200
    var currencyRate: Double = 0.0
    
    var isEdit = false
    var editingSuccess = false
    
    var isSelectedRadio01: Bool = false
    var isSelectedRadio02: Bool = false
    var isSelectedRadio11: Bool = false
    var isSelectedRadio12: Bool = false
    var isSelectedRadio13: Bool = false
    
    var isSelectedPromotion0: Bool = false
    var isSelectedPromotion1: Bool = false
    var isSelectedPromotion2: Bool = false
    var isSelectedPromotion3: Bool = false
    var isSelectedPromotion4: Bool = false
    
    var productItem: ProductListModel!
    var selectedRadio1: NSInteger = 0
    var selectedRadio2: NSInteger = 0
    
    var arrayCategory = NSArray()
    var arrayCategory2 = NSArray()
    
    var selectedCategoryId = Int64()
    var selectedCategory2Id = Int64()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setupNavBar()
        self.initMainView()
        self.setupTheme()
        self.getData()
        self.setupUI()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        
        storeSelectLabel.textColor = MainColors.themeEndColors[selectedTheme]
        categorySelectLabel.textColor = MainColors.themeEndColors[selectedTheme]
        category2SelectLabel.textColor = MainColors.themeEndColors[selectedTheme]
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
    
    func initMainView() {
        // category
        categorySelectLabel.text = "更多" + " \u{2228}"
        category2SelectLabel.text = "清选择商品分类" + " \u{2228}"
        
        arrayCategory = NSArray.init()
        arrayCategory2 = NSArray.init()
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(UINib(nibName: "MyStoreCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "MyStoreCategoryTableViewCell")
        
        
        tableList2.delegate = self
        tableList2.dataSource = self
        tableList2.register(UINib(nibName: "MyStoreCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "MyStoreCategoryTableViewCell")
        
        tableList.layer.masksToBounds = true
        tableList.layer.cornerRadius = 4
        
        tableList2.layer.masksToBounds = true
        tableList2.layer.cornerRadius = 4
        
        tableList.isHidden = true
        tableList2.isHidden = true
        
        // radio
        isSelectedRadio01 = !isSelectedRadio01
        isSelectedRadio02 = !isSelectedRadio01
        
        self.setRadio01(flag: isSelectedRadio01)
        self.setRadio02(flag: isSelectedRadio02)
        
        isSelectedRadio11 = true
        self.setRadio11(flag: isSelectedRadio11)
        
        // btn promotion
        btnPromotion0.layer.masksToBounds = true
        btnPromotion0.layer.cornerRadius = 5
        btnPromotion1.layer.masksToBounds = true
        btnPromotion1.layer.cornerRadius = 5
        btnPromotion2.layer.masksToBounds = true
        btnPromotion2.layer.cornerRadius = 5
        btnPromotion3.layer.masksToBounds = true
        btnPromotion3.layer.cornerRadius = 5
        btnPromotion4.layer.masksToBounds = true
        btnPromotion4.layer.cornerRadius = 5
        
        self.setChoosePromotionButton0(isSelected: isSelectedPromotion0)
        self.setChoosePromotionButton1(isSelected: isSelectedPromotion1)
        self.setChoosePromotionButton2(isSelected: isSelectedPromotion2)
        self.setChoosePromotionButton3(isSelected: isSelectedPromotion3)
        self.setChoosePromotionButton4(isSelected: isSelectedPromotion4)

        // collection views
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.alwaysBounceHorizontal = true
        collectionView1.isScrollEnabled = true
        collectionView1.allowsSelection = false
        collectionView1.register(UINib.init(nibName: "MyStorePorductMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyStorePorductMediaCollectionViewCell")
        
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.alwaysBounceHorizontal = true
        collectionView2.isScrollEnabled = true
        collectionView2.allowsSelection = false
        collectionView2.register(UINib.init(nibName: "MyStorePorductMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyStorePorductMediaCollectionViewCell")
        
        collectionView3.delegate = self
        collectionView3.dataSource = self
        collectionView3.alwaysBounceHorizontal = true
        collectionView3.isScrollEnabled = true
        collectionView3.allowsSelection = false
        collectionView3.register(UINib.init(nibName: "MyStorePorductMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyStorePorductMediaCollectionViewCell")
        
        collectionView4.delegate = self
        collectionView4.dataSource = self
        collectionView4.alwaysBounceHorizontal = true
        collectionView4.isScrollEnabled = true
        collectionView4.allowsSelection = false
        collectionView4.register(UINib.init(nibName: "MyStorePorductMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyStorePorductMediaCollectionViewCell")
        
        collectionView5.delegate = self
        collectionView5.dataSource = self
        collectionView5.alwaysBounceHorizontal = true
        collectionView5.isScrollEnabled = true
        collectionView5.allowsSelection = false
        collectionView5.register(UINib.init(nibName: "MyStorePorductMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyStorePorductMediaCollectionViewCell")
        
        self.automaticallyAdjustsScrollViewInsets = true
        
    }
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.restitutionRate != nil {
            self.restitutionRate = appDelegate.restitutionRate
        } else {
            self.restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        // slider
        treasureRatioSlider.setValue(100, animated: true)
        treasureRatioLabel.text = String(Int(100))
        setPaiValueLabels(Int(100) - 1)
        
        descriptionTextView.placeholder = "请输入商品详情"
        
        treasureRatioLabel.text = String(Int(treasureRatioSlider.value))
        //        checkBoxGroup = BEMCheckBoxGroup(checkBoxes: [paiCheckBox, cnyCheckBox])
        //        checkBoxGroup.mustHaveSelection = true
        //        checkBoxGroup.selectedCheckBox = paiCheckBox
        //        paiCheckBox.delegate = self
        //        cnyCheckBox.delegate = self
        
        self.setPaiValueLabels(49)
        
        if isEdit {
            storeSelectLabel.text = productItem.store?.name
            categorySelectLabel.text = (productItem.category?.name)! + " \u{2228}"
            productNameField.text = productItem.name
            descriptionTextView.text = productItem.description
            priceField.text = productItem.price
            inventoryField.text = String(productItem.amount!)
            
            isSelectedRadio11 = productItem.propertyAll!
            isSelectedRadio12 = productItem.propertyRecent!
            isSelectedRadio13 = productItem.propertyActive!
            
            self.setRadio11(flag: isSelectedRadio11)
            self.setRadio12(flag: isSelectedRadio12)
            self.setRadio13(flag: isSelectedRadio13)
            
            isSelectedPromotion0 = productItem.deliveryOnOff!
            isSelectedPromotion1 = productItem.refundOnOff!
            isSelectedPromotion2 = false
            isSelectedPromotion3 = productItem.refundInWeek!
            isSelectedPromotion4 = false
            
            self.setChoosePromotionButton0(isSelected: isSelectedPromotion0)
            self.setChoosePromotionButton1(isSelected: isSelectedPromotion1)
            self.setChoosePromotionButton2(isSelected: isSelectedPromotion2)
            self.setChoosePromotionButton3(isSelected: isSelectedPromotion3)
            self.setChoosePromotionButton4(isSelected: isSelectedPromotion4)

//            if productItem.qrimage! != "" {
//                customQRCodeImage = CustomImageModel.init(imageURL: productItem.qrimage, image: nil, isImage: false)
//                let resizedUrl = Utils.getResizedImageUrlString(productItem.qrimage!, width: "800")
//                //                self.QRCodeImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: nil)
//            }
            
            treasureRatioSlider.setValue(Float(productItem.treasureRatio!), animated: true)
            treasureRatioLabel.text = String(productItem.treasureRatio!)
            
            var treasure = Int(productItem.treasureRatio!)
            if treasure < 1 {
                treasure = 1
                treasureRatioLabel.text = "1"
            }
            setPaiValueLabels(treasure - 1)
            
            if productItem.paymentType! == 1 {
                //                checkBoxGroup.selectedCheckBox = paiCheckBox
                //                self.showTreasureGroup(true)
            } else if productItem.paymentType! == 2 {
                //                checkBoxGroup.selectedCheckBox = cnyCheckBox
                //                self.showTreasureGroup(false)
            }
            
            // image
            for image in productItem.images! {
                let url = URL(string: image)
                if let imageData = try? Data(contentsOf: url!) {
                    let img: UIImage = UIImage(data: imageData)!
                    
                    let customImage = CustomImageModel.init(imageURL: "imageUrl", image: img, isImage: true)
                    customImageArray.append(customImage)
                }
            }
            
            // category
            selectedCategoryId = (productItem.category?.id!)!
            selectedCategory2Id = productItem.subCategoryId!
            
            self.requestCategorySubName(pid: NSInteger(selectedCategoryId), sid: NSInteger(selectedCategory2Id))
            
            navBar.lblTitle.text = "变更商品"
            postButton.setTitle("变更商品", for: .normal)
            //            self.updateTableViewHeight()
        }
        
    }
    
    func getData() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.storeMine { (json, success) in
            if success {
                ProgressHUD.dismiss()
                print("Store Mine...:")
                print(json)
                self.setupUI()
                self.stores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                
                if self.stores.count > 0 {
                    self.storeSelectLabel.text = self.stores.first?.name
                    self.categorySelectLabel.text = self.stores.first?.category?.name
                    self.selectedCategoryId = (self.stores.first?.category?.id!)!
                    self.selectedStoreId = self.stores.first?.storeId!
                }
                
            } else {
                // try again...
                MyAPI.shared.storeMine(completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.setupUI()
                        self.stores = StoreDetailModel.getStoreDetailsFromJson(json["store"])
                        
                        if self.stores.count > 0 {
                            self.storeSelectLabel.text = self.stores.first?.name
                            self.selectedStoreId = self.stores.first?.storeId!
                            self.categorySelectLabel.text = self.stores.first?.category?.name
                            self.selectedCategoryId = (self.stores.first?.category?.id!)!
                            
                        }
                        
                    } else {
                        ProgressHUD.showErrorWithStatus("无法获取商店的详细信息. 再试一次.")
                    }
                })
            }
        }
        
    }
    
    //------------------------------------
    // label - pai value
    //------------------------------------
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
    
    //------------------------------------
    // slider
    //------------------------------------
    @IBAction func selectSliderMinus(_ sender: Any) {
        Utils.applyTouchEffect(sliderMinusView)
        let sliderValue = treasureRatioSlider.value
        if sliderValue > 1 {
            treasureRatioSlider.setValue(treasureRatioSlider.value - 1, animated: true)
            treasureRatioLabel.text = String(Int(treasureRatioSlider.value))
            setPaiValueLabels(Int(treasureRatioSlider.value) - 1)
        }
    }
    
    @IBAction func selectSliderPlus(_ sender: Any) {
        Utils.applyTouchEffect(sliderPlusView)
        let sliderValue = treasureRatioSlider.value
        if sliderValue < 100 {
            treasureRatioSlider.setValue(treasureRatioSlider.value + 1, animated: true)
            treasureRatioLabel.text = String(Int(treasureRatioSlider.value))
            setPaiValueLabels(Int(treasureRatioSlider.value) - 1)
        }
    }
    
    @IBAction func treasureSliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        treasureRatioLabel.text = String(value)
        
        setPaiValueLabels(value - 1)
    }
    
    //------------------------------------
    // radio
    //------------------------------------
    @IBAction func tapBtnRadio01(_ sender: Any) {
        isSelectedRadio01 = !isSelectedRadio01
        isSelectedRadio02 = !isSelectedRadio01
        
        self.setRadio01(flag: isSelectedRadio01)
        self.setRadio02(flag: isSelectedRadio02)
    }
    
    
    @IBAction func tapBtnRadio02(_ sender: Any) {
        isSelectedRadio02 = !isSelectedRadio02
        isSelectedRadio01 = !isSelectedRadio02
        
        self.setRadio02(flag: isSelectedRadio02)
        self.setRadio01(flag: isSelectedRadio01)
    }
    
    func setRadio01(flag: Bool) {
        if flag == true {
            imgRadio01.image = UIImage.init(named: "my_store_radio_on.png")
        } else {
            imgRadio01.image = UIImage.init(named: "my_store_radio_off.png")
        }
    }
    
    func setRadio02(flag: Bool) {
        if flag == true {
            imgRadio02.image = UIImage.init(named: "my_store_radio_on.png")
        } else {
            imgRadio02.image = UIImage.init(named: "my_store_radio_off.png")
        }
    }
    
    @IBAction func tapBtnRadio11(_ sender: Any) {
        isSelectedRadio11 = !isSelectedRadio11
        self.setRadio11(flag: isSelectedRadio11)
    }
    
    @IBAction func tapBtnRadio12(_ sender: Any) {
        isSelectedRadio12 = !isSelectedRadio12
        self.setRadio12(flag: isSelectedRadio12)
    }
    
    @IBAction func tapBtnRadio13(_ sender: Any) {
        isSelectedRadio13 = !isSelectedRadio13
        self.setRadio13(flag: isSelectedRadio13)
    }
    
    func setRadio11(flag: Bool) {
        if flag == true {
            imgRadio11.image = UIImage.init(named: "my_store_radio_on.png")
        } else {
            imgRadio11.image = UIImage.init(named: "my_store_radio_off.png")
        }
    }
    
    func setRadio12(flag: Bool) {
        if flag == true {
            imgRadio12.image = UIImage.init(named: "my_store_radio_on.png")
        } else {
            imgRadio12.image = UIImage.init(named: "my_store_radio_off.png")
        }
    }
    
    func setRadio13(flag: Bool) {
        if flag == true {
            imgRadio13.image = UIImage.init(named: "my_store_radio_on.png")
        } else {
            imgRadio13.image = UIImage.init(named: "my_store_radio_off.png")
        }
    }
    
    //------------------------------------
    // btn promotion
    //------------------------------------
    @IBAction func tapBtnPromotion0(_ sender: Any) {
        isSelectedPromotion0 = !isSelectedPromotion0
        self.setChoosePromotionButton0(isSelected: isSelectedPromotion0)
    }
    
    @IBAction func tapBtnPromotion1(_ sender: Any) {
        isSelectedPromotion1 = !isSelectedPromotion1
        self.setChoosePromotionButton1(isSelected: isSelectedPromotion1)
    }
    
    @IBAction func tapBtnPromotion2(_ sender: Any) {
        isSelectedPromotion2 = !isSelectedPromotion2
        self.setChoosePromotionButton2(isSelected: isSelectedPromotion2)
    }
    
    @IBAction func tapBtnPromotion3(_ sender: Any) {
        isSelectedPromotion3 = !isSelectedPromotion3
        self.setChoosePromotionButton3(isSelected: isSelectedPromotion3)
    }
    
    @IBAction func tapBtnPromotion4(_ sender: Any) {
        isSelectedPromotion4 = !isSelectedPromotion4
        self.setChoosePromotionButton4(isSelected: isSelectedPromotion4)
    }
    
    func setChoosePromotionButton0(isSelected: Bool) {
        if isSelected == true {
            btnPromotion0.tintColor = UIColor.white
            btnPromotion0.ts_setBackgroundColor(UIColor.init(ts_hexString: "e76593"), forState: .normal)
        } else {
            btnPromotion0.tintColor = UIColor.darkGray
            btnPromotion0.ts_setBackgroundColor(UIColor.init(ts_hexString: "d9d9d9"), forState: .normal)
        }
    }
    
    func setChoosePromotionButton1(isSelected: Bool) {
        if isSelected == true {
            btnPromotion1.tintColor = UIColor.white
            btnPromotion1.ts_setBackgroundColor(UIColor.init(ts_hexString: "e76593"), forState: .normal)
        } else {
            btnPromotion1.tintColor = UIColor.darkGray
            btnPromotion1.ts_setBackgroundColor(UIColor.init(ts_hexString: "d9d9d9"), forState: .normal)
        }
    }
    
    func setChoosePromotionButton2(isSelected: Bool) {
        if isSelected == true {
            btnPromotion2.tintColor = UIColor.white
            btnPromotion2.ts_setBackgroundColor(UIColor.init(ts_hexString: "e76593"), forState: .normal)
        } else {
            btnPromotion2.tintColor = UIColor.darkGray
            btnPromotion2.ts_setBackgroundColor(UIColor.init(ts_hexString: "d9d9d9"), forState: .normal)
        }
    }
    
    func setChoosePromotionButton3(isSelected: Bool) {
        if isSelected == true {
            btnPromotion3.tintColor = UIColor.white
            btnPromotion3.ts_setBackgroundColor(UIColor.init(ts_hexString: "e76593"), forState: .normal)
        } else {
            btnPromotion3.tintColor = UIColor.darkGray
            btnPromotion3.ts_setBackgroundColor(UIColor.init(ts_hexString: "d9d9d9"), forState: .normal)
        }
    }
    
    func setChoosePromotionButton4(isSelected: Bool) {
        if isSelected == true {
            btnPromotion4.tintColor = UIColor.white
            btnPromotion4.ts_setBackgroundColor(UIColor.init(ts_hexString: "e76593"), forState: .normal)
        } else {
            btnPromotion4.tintColor = UIColor.darkGray
            btnPromotion4.ts_setBackgroundColor(UIColor.init(ts_hexString: "d9d9d9"), forState: .normal)
        }
    }
    

    //------------------------------------
    // btn category
    //------------------------------------
    @IBAction func tapBtnFirstCategory(_ sender: Any) {
        self.requestCategoryFirst()
    }
    
    @IBAction func tapBtnSecondCategory(_ sender: Any) {
        if arrayCategory2.count > 0 {
            tableList2.isHidden = false
        } else {
            self.requestCategorySub(index: NSInteger(selectedCategoryId), isShowTable: true)
        }
    }
    
    // table view datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableList {
            if ((arrayCategory.count) > 0) {
                return (arrayCategory.count)
            } else {
                return 0
            }
            
        } else if tableView == tableList2 {
            if ((arrayCategory2.count) > 0) {
                return (arrayCategory2.count)
            } else {
                return 0
            }
            
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyStoreCategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyStoreCategoryTableViewCell", for: indexPath) as! MyStoreCategoryTableViewCell
        if arrayCategory.count > 0 {
            cell.selectionStyle = .none
            
            if tableView == tableList {
                cell.setInfo(dic: arrayCategory[indexPath.row] as! NSDictionary)
            }
            
            if tableView == tableList2 {
                cell.setInfo(dic: arrayCategory2[indexPath.row] as! NSDictionary)
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableList {
            // get first category's sub categories
            if arrayCategory.count > 0 && (arrayCategory[indexPath.row] as! NSDictionary)["id"] != nil {
                let dicFirst = arrayCategory[indexPath.row] as! NSDictionary
                selectedCategoryId = Int64(dicFirst["id"] as! NSInteger)
                let categoryName = dicFirst["name"] as! String
                self.requestCategorySub(index: NSInteger(selectedCategoryId), isShowTable: false)
                
                categorySelectLabel.text = categoryName + " \u{2228}"
                category2SelectLabel.text = "清选择商品分类" + " \u{2228}"
                selectedCategory2Id = Int64()
                
                tableList.isHidden = true
            }
        }
        
        if tableView == tableList2 {
            if arrayCategory2.count > 0 && (arrayCategory2[indexPath.row] as! NSDictionary)["id"] != nil {
                let dicSecond = arrayCategory2[indexPath.row] as! NSDictionary
                selectedCategory2Id = Int64(dicSecond["id"] as! NSInteger)
                let category2Name = dicSecond["name"] as! String
                
                category2SelectLabel.text = category2Name + " \u{2228}"
                
                tableList2.isHidden = true
                
            }
        }
        
        return
    }
    
    // collection view datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            return 1
        }
        
        if collectionView == collectionView2 {
            return 1
        }
        
        if collectionView == collectionView3 {
            if customImageArray.count > 0 {
                if customImageArray.count >= 6 {
                    return 6
                } else {
                    return customImageArray.count + 1
                }
            } else {
                return customImageArray.count + 1
            }
        }
        
        if collectionView == collectionView4 {
            if customImageArray4.count > 0 {
                if customImageArray4.count >= 6 {
                    return 6
                } else {
                    return customImageArray4.count + 1
                }
            } else {
                return customImageArray4.count + 1
            }
        }
        
        if collectionView == collectionView5 {
            if customImageArray5.count > 0 {
                if customImageArray5.count >= 15 {
                    return 15
                } else {
                    return customImageArray5.count + 1
                }
            } else {
                return customImageArray5.count + 1
            }
            
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyStorePorductMediaCollectionViewCell", for: indexPath) as! MyStorePorductMediaCollectionViewCell
        cell.delegate = self
        
        if collectionView == collectionView1 {
            cell.collectionViewIndex = 1
            if customImageArray1.count == 0 {
                cell.setAdd(isImage: true)
                
            } else {
                cell.index = indexPath.row
                cell.setInfo(model: customImageArray1[indexPath.row], isImage: true)
            }
            
            return cell
        }
        
        if collectionView == collectionView2 {
            cell.collectionViewIndex = 2
            if customImageArray2.count == 0 {
                cell.setAdd(isImage: false)
                
            } else {
                cell.index = indexPath.row
                cell.setInfo(model: customImageArray2[indexPath.row], isImage: false)
            }
            return cell
        }
        
        if collectionView == collectionView3 {
            cell.collectionViewIndex = 3
            if customImageArray.count == 0 {
                cell.setAdd(isImage: true)
                
            } else {
                if indexPath.row == customImageArray.count {
                    cell.setAdd(isImage: true)
                    
                } else {
                    cell.index = indexPath.row
                    cell.setInfo(model: self.customImageArray[indexPath.row], isImage: true)
                }
            }
            
            return cell
        }
        
        if collectionView == collectionView4 {
            cell.collectionViewIndex = 4
            if customImageArray4.count == 0 {
                cell.setAdd(isImage: true)
                
            } else {
                if indexPath.row == customImageArray4.count {
                    cell.setAdd(isImage: true)
                    
                } else {
                    cell.index = indexPath.row
                    cell.setInfo(model: self.customImageArray4[indexPath.row], isImage: true)
                }
            }
            
            return cell
        }
        
        if collectionView == collectionView5 {
            cell.collectionViewIndex = 5
            if customImageArray5.count == 0 {
                cell.setAdd(isImage: true)
                
            } else {
                if indexPath.row == customImageArray5.count {
                    cell.setAdd(isImage: true)
                    
                } else {
                    cell.index = indexPath.row
                    cell.setInfo(model: self.customImageArray5[indexPath.row], isImage: true)
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.size.width
        
        let wi = (collectionWidth - 10 * 2) / 3
        let he = wi
        
        return CGSize(width: wi, height: he)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    // MARK: - CollectionViewcell delegate
    func didTapButtonMyStorePorductMediaCollectionViewCellAdd(collectionViewIndex: NSInteger) {
        selectedCollectionViewIndex = collectionViewIndex
        
        switch collectionViewIndex {
        case 1:   // image
            self.presentImageSheet(title: "首页展示页商品图")
            break
            
        case 2:   // video
            self.presentImageSheet(title: "首页展示页商品视频")
            break
            
        case 3:   // image
            self.presentImageSheet(title: "轮播商品图片")
            break
            
        case 4:   // image
            self.presentImageSheet(title: "商品规格描述")
            break
            
        case 5:   // image
            self.presentImageSheet(title: "商品图片")
            break
            
        default:
            break
            
        }
    }
    
    func didTapButtonMyStorePorductMediaCollectionViewCellDelete(index: NSInteger, collectionViewIndex: NSInteger) {
        if collectionViewIndex == 1  {
            customImageArray1.remove(at: index)
            collectionView1.reloadData()
            return
        }
        
        if collectionViewIndex == 2 {
            customImageArray2.remove(at: index)
            collectionView2.reloadData()
            return
        }
        
        if collectionViewIndex == 3 {
            customImageArray.remove(at: index)
            collectionView3.reloadData()
            return
        }
        
        if collectionViewIndex == 4 {
            customImageArray4.remove(at: index)
            collectionView4.reloadData()
            return
        }
        
        if collectionViewIndex == 5 {
            customImageArray5.remove(at: index)
            collectionView5.reloadData()
            return
        }
        
    }
    
    private func presentImageSheet(title: String) {
        let sheet = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
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
        
        if selectedCollectionViewIndex != 2 {
            sheet.addAction(photoAction)
        }
        
        sheet.addAction(cancelAction)
        
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        if UserInstance.hasVerifiedStore() {
            if selectedCollectionViewIndex == 1 {
                if self.customImageArray1.count > 1 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多1张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 2 {
                if self.customImageArray2.count > 1 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多1张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 3 {
                if self.customImageArray.count > 6 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多6张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 4 {
                if self.customImageArray4.count > 6 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多6张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 5 {
                if self.customImageArray5.count > 15 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多15张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
        } else {
            if selectedCollectionViewIndex == 1 {
                if self.customImageArray1.count > 1 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多1张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 2 {
                if self.customImageArray2.count > 1 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多1张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 3 {
                if self.customImageArray.count > 6 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多6张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 4 {
                if self.customImageArray4.count > 6 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多6张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
            if selectedCollectionViewIndex == 5 {
                if self.customImageArray5.count > 15 {
                    ProgressHUD.showWarningWithStatus("你可以添加最多15张.")
                } else {
                    DispatchQueue.main.async {
                        self.present(sheet, animated: true, completion: nil)
                    }
                }
                
                return
            }
            
        }
        
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
                    
                    if self.selectedCollectionViewIndex == 2 {
                        imagePicker.mediaTypes = NSArray.init(object: kUTTypeMovie) as! [String]
                        imagePicker.videoMaximumDuration = 60.0 // 60s
                        imagePicker.videoQuality = .typeMedium
                    }
                    
                    DispatchQueue.main.async {
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                }
            })
        } else if authStatus == .restricted || authStatus == .denied {
            self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
        } else if authStatus == .authorized {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            if self.selectedCollectionViewIndex == 2 {
                imagePicker.mediaTypes = NSArray.init(object: kUTTypeMovie) as! [String]
                imagePicker.videoMaximumDuration = 60.0 // 60s
                imagePicker.videoQuality = .typeMedium
            }
            
            DispatchQueue.main.async {
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    private func selectLibrary() {
        var maxedNumber = 1
        if selectedCollectionViewIndex == 1 {
            let maxNumber = 1 - self.customImageArray1.count
            maxedNumber = maxNumber
            
        } else if selectedCollectionViewIndex == 2 {
            let maxNumber = 1 - self.customImageArray2.count
            maxedNumber = maxNumber
            
        } else if selectedCollectionViewIndex == 3 {
            let maxNumber = 6 - self.customImageArray.count
            maxedNumber = maxNumber
            
        } else if selectedCollectionViewIndex == 4 {
            let maxNumber = 6 - self.customImageArray4.count
            maxedNumber = maxNumber
            
        } else if selectedCollectionViewIndex == 5 {
            let maxNumber = 15 - self.customImageArray5.count
            maxedNumber = maxNumber
            
        }
        
        self.presentImagePickerController(
            maxNumberOfSelections: maxedNumber,
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
                    
                    if self?.selectedCollectionViewIndex == 1 {
                        let customImage = CustomImageModel.init(imageURL: "imageUrl", image: image, isImage: true)
                        self?.customImageArray1.append(customImage)
                        
                        DispatchQueue.main.async {
                            self?.collectionView1.reloadData()
                        }
                        
                    } else if self?.selectedCollectionViewIndex == 2 {
                        let customImage = CustomImageModel.init(imageURL: "imageUrl", image: image, isImage: true)
                        self?.customImageArray2.append(customImage)
                        
                        DispatchQueue.main.async {
                            self?.collectionView2.reloadData()
                        }
                        
                    } else if self?.selectedCollectionViewIndex == 3 {
                        let customImage = CustomImageModel.init(imageURL: "imageUrl", image: image, isImage: true)
                        self?.customImageArray.append(customImage)
                        
                        DispatchQueue.main.async {
                            self?.collectionView3.reloadData()
                        }
                        
                    } else if self?.selectedCollectionViewIndex == 4 {
                        let customImage = CustomImageModel.init(imageURL: "imageUrl", image: image, isImage: true)
                        self?.customImageArray4.append(customImage)
                        
                        DispatchQueue.main.async {
                            self?.collectionView4.reloadData()
                        }
                        
                    } else if self?.selectedCollectionViewIndex == 5 {
                        let customImage = CustomImageModel.init(imageURL: "imageUrl", image: image, isImage: true)
                        self?.customImageArray5.append(customImage)
                        
                        DispatchQueue.main.async {
                            self?.collectionView5.reloadData()
                        }
                        
                    }
                    
                }
                
            }
            
            }, completion: { () -> Void in
                print("completion")
        })
    }
    
    // MARK: - UIImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                
                if self.selectedCollectionViewIndex == 1 {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    self.customImageArray1.append(customImage)
                    self.collectionView1.reloadData()
                    
                } else if self.selectedCollectionViewIndex == 2 {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    self.customImageArray2.append(customImage)
                    self.collectionView2.reloadData()
                    
                } else if self.selectedCollectionViewIndex == 3 {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    self.customImageArray.append(customImage)
                    self.collectionView3.reloadData()
                    
                } else if self.selectedCollectionViewIndex == 4 {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    self.customImageArray4.append(customImage)
                    self.collectionView4.reloadData()
                    
                } else if self.selectedCollectionViewIndex == 4 {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    self.customImageArray4.append(customImage)
                    self.collectionView4.reloadData()
                    
                } else if self.selectedCollectionViewIndex == 5 {
                    let customImage = CustomImageModel.init(imageURL: nil, image: image, isImage: true)
                    self.customImageArray5.append(customImage)
                    self.collectionView5.reloadData()
                    
                }
                
                
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - nav bar delegate
    func didSelectBack() {
        if self.isEdit {
            if editingSuccess {
                let info: [String : Any] = ["success" : editingSuccess]
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_ITEM_EDIT), object: nil, userInfo: info)
            }
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextfeildDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("End Editing...")
        
        let sliderValue = Int(treasureRatioLabel.text!)!
        self.setPaiValueLabels(sliderValue)
    }
    
    // MARK: - BEMCheckBoxDelegate
    func didTap(_ checkBox: BEMCheckBox) {
//        if paiCheckBox.on {
//            showTreasureGroup(true)
//        } else if cnyCheckBox.on {
//            showTreasureGroup(false)
//        }
    }
    
    @IBAction func tapBtnPost(_ sender: Any) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if !validateFields() {
            return
        }
        
        self.postProductImageArray()
        
    }
    
    private func validateFields() -> Bool {
        let productName = productNameField.text
        let productDescription = descriptionTextView.text
        let productPrice = priceField.text
        let productAmount = inventoryField.text
//        let paiCheck = paiCheckBox.on
//        let cnyCheck = cnyCheckBox.on
        
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
        
//        if !cnyCheck && !paiCheck {
//            ProgressHUD.showWarningWithStatus("请选择付款方式.")
//            return false
//        }
        
        if customImageArray.count < 1 {
            ProgressHUD.showWarningWithStatus("请选择张的首页展示页商品图.")
            return false
        }
/*
        if customImageArray2.count < 1 {
            ProgressHUD.showWarningWithStatus("请选择1张的首页展示页商品视频.")
            return false
        }
        
        if customImageArray3.count < 1 {
            ProgressHUD.showWarningWithStatus("请选择1张的轮播商品图片.")
            return false
        }
        
        if customImageArray4.count < 1 {
            ProgressHUD.showWarningWithStatus("请选择1张的商品规格描述.")
            return false
        }
        
        if customImageArray5.count < 1 {
            ProgressHUD.showWarningWithStatus("请选择1张的商品图片.")
            return false
        }
  */
        
        
        return true
    }
    
    func postProductImageArray() {
        var imageNames = [String](repeatElement("", count: self.customImageArray.count))
        var objectKeys = [String]()
        var images = [UIImage]()
        var isImages = [Bool]()
        
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
                isImages.append(true)
                
            } else {
                imageNames[i] = customImage.imageURL!
            }
        }
        
        if objectKeys.count > 0 {
            ProgressHUD.showWithStatus()
            AliyunUtil.shared.putImages(images, objectKeys: objectKeys, imageUrls: [String](), isImages: isImages) { (results) in
                ProgressHUD.dismiss()
                
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
                
                DispatchQueue.main.async {
                    self.postButton.isEnabled = true
                }

                self.productPost(imageNames: imageNames, qrcodeImageName: qrcodeImageName)
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

    func postProductImageArray1() {
        var imageNames = [String](repeatElement("", count: self.customImageArray.count))
        var objectKeys = [String]()
        var images = [UIImage]()
        var imageURLs = [String]()
        var isImages = [Bool]()
        
        self.postButton.isEnabled = false
        
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
                imageURLs.append(customImage.imageURL!)
                isImages.append(customImage.isImage!)
                
            } else {
                let sufix = ".mp4"
                let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
                let objectKey = Constants.ARTICLE + "/\(UserInstance.userId!)/" + "\(timestamp)" + sufix
                
                imageNames[i] = Constants.ALIYUN_URL_PREFIX + objectKey
                
                objectKeys.append(objectKey)
                images.append(customImage.image!)
                imageURLs.append(customImage.imageURL!)
                isImages.append(customImage.isImage!)
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
                
                self.postButton.isEnabled = true
                if imageNames.count < 3 {
                    // images upload error
                    ProgressHUD.showErrorWithStatus("首页展示页商品图上传错误")
                    return
                }
                
                // call product post or update api
//                self.productPost(imageNames: imageNames)
            }
            
        } else {
            // call product post or update api
            self.postButton.isEnabled = true
//            self.productPost(imageNames: imageNames)
        }
        
    }
    
    private func productPost(imageNames: [String], qrcodeImageName: String) {
        DispatchQueue.main.async {
            
            self.productName = self.productNameField.text!
            self.productDescription = self.descriptionTextView.text!
            self.productPrice = self.priceField.text!
            self.productAmount = self.inventoryField.text!
            
            let paymentType = 1
//            if self.paiCheckBox.on && self.cnyCheckBox.on {
//                paymentType = 3
//            } else if self.paiCheckBox.on {
//                paymentType = 1
//            } else if self.cnyCheckBox.on {
//                paymentType = 2
//            }
            
            let product_images = "[\"" + (imageNames.map{$0}).joined(separator: "\", \"") + "\"]"
            
            var parameters: [String : Any] = [
                "category" : String(self.selectedCategoryId),
                "sub_category": String(self.selectedCategory2Id),
                "name" : self.productName,
                "description" : self.productDescription,
                "store" : String(self.selectedStoreId),
                "price" : self.productPrice,
                "amount" : self.productAmount,
                "currency" : String(paymentType),
                "images" : product_images,
                "property_all": self.isSelectedRadio11,
                "property_recent": self.isSelectedRadio12,
                "property_active": self.isSelectedRadio13,
                "delivery_on_off": self.isSelectedPromotion0,
                "refund_on_off": self.isSelectedPromotion1,
                "refund_in_week": self.isSelectedPromotion3
            ]
            
            if paymentType == 1 {
                parameters["profit_ratio"] = self.treasureRatioLabel.text!
            }
            
            print(">>>> parameters:\n", parameters)
            
            ProgressHUD.showWithStatus()
            
            if self.isEdit {
                parameters["id"] = String(self.productItem.id!)
                
                MyAPI.shared.itemChange(params: parameters, completion: { (json, success) in
                    ProgressHUD.dismiss()
                    if success {
                        ProgressHUD.showSuccessWithStatus("成功改变了")
                        //                        self.deleteImagesFromAliyun()
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
    
    func requestCategoryFirst() {
        let parameters: Parameters = [:]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getCategoryFirst(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> first json:\n", json)
                self.arrayCategory = NSArray.init(array: json["category"] as! NSArray)
                self.tableList.reloadData()
                
                self.tableList.isHidden = false
            }
            
        }
        
    }
    
    func requestCategorySub(index: NSInteger, isShowTable: Bool) {
        let parameters: Parameters = [
            "parent": index
        ]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getCategorySub(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> second json:\n", json)
                self.arrayCategory2 = NSArray.init(array: json["category"] as! NSArray)
                
                if self.arrayCategory2.count > 0 {
                    self.tableList2.reloadData()
                    
                    if isShowTable == true {
                        self.tableList2.isHidden = false
                    } else {
                        self.tableList2.isHidden = true
                    }
                }
                
            } else {
                CategoryAPI.shared.getCategorySub(params: parameters) { (json, success) in
                    if success {
                        self.arrayCategory2 = NSArray.init(array: json["category"] as! NSArray)
                        
                        if self.arrayCategory2.count > 0 {
                            self.tableList2.reloadData()
                            
                            if isShowTable == true {
                                self.tableList2.isHidden = false
                            } else {
                                self.tableList2.isHidden = true
                            }
                        }

                    } else {
                        return
                    }
                }
            }
            
        }
        
    }
    
    func requestCategorySubName(pid: NSInteger, sid: NSInteger) {
        let parameters: Parameters = [
            "parent": pid
        ]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getCategorySub(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> second json:\n", json)
                let arrayCat2 = NSArray.init(array: json["category"] as! NSArray)
                for subCategory in arrayCat2 {
                    let sub = subCategory as! NSDictionary
                    if (sub["id"] as! NSInteger) == sid {
                        self.category2SelectLabel.text = (sub["name"] as! String) + " \u{2228}"
                        return
                    }
                }
                
            } else {
                CategoryAPI.shared.getCategorySub(params: parameters) { (json, success) in
                    if success {
                        let arrayCat2 = NSArray.init(array: json["category"] as! NSArray)
                        for subCategory in arrayCat2 {
                            let sub = subCategory as! NSDictionary
                            if (sub["id"] as! NSInteger) == sid {
                                self.category2SelectLabel.text = (sub["name"] as! String) + " \u{2228}"
                                return
                            }
                        }
                        
                    } else {
                        return
                    }
                }
            }
            
        }
        
    }
    
}
