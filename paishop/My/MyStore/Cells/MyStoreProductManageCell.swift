
import UIKit
import SKPhotoBrowser

class MyStoreProductManageCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    
    var product: ProductListModel!
    var index: Int!
    var myStoreProductManageVC: MyStoreProductManageVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ product: ProductListModel, index: Int, vc: MyStoreProductManageVC) {
        self.index = index
        self.myStoreProductManageVC = vc
        self.product = product
        
        if (product.images?.count)! > 0 {
            if let productUrl = product.images?.first, productUrl != "" {
                let resizedProductUrl = Utils.getResizedImageUrlString(productUrl, width: "400")
                productImageView.setImageWithURLString(resizedProductUrl, placeholderImage: ImageAsset.default_image.image)
            }
        }
        
        descriptionLabel.text = product.name
        
        if product.status! == 0 {
            stateButton.isEnabled = false
            stateButton.imageView?.alpha = 0.3
            stateLabel.text = "拒绝"
        } else if product.status! == 1 {
            stateButton.isEnabled = true
            stateButton.imageView?.alpha = 1.0
            if product.active! {
                stateButton.setImage(ImageAsset.my_store_download.image, for: .normal)
                stateLabel.text = "上架"
            } else {
                stateButton.setImage(ImageAsset.my_store_upload.image, for: .normal)
                stateLabel.text = "未上架"
            }
        } else if product.status! == 2 {
            stateButton.isEnabled = false
            stateButton.imageView?.alpha = 0.3
            stateLabel.text = "有待"
        }
        
        let productImageTap = UITapGestureRecognizer(target: self, action: #selector(tapProductImageView))
        productImageView.isUserInteractionEnabled = true
        productImageView.addGestureRecognizer(productImageTap)
        
    }
    
    
    @IBAction func changeState(_ sender: UIButton) {
        if product.active! {
            myStoreProductManageVC.presentAlert("你真的想未上架吗?", completion: {
                self.inactiveProduct()
            })
        } else {
            myStoreProductManageVC.presentAlert("你真的想上架吗?", completion: {
                self.activeProduct()
            })
        }
        
    }
    
    @IBAction func selectEdit(_ sender: UIButton) {
        myStoreProductManageVC.editingIndex = index
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreProductPostVC1.nameOfClass) as! MyStoreProductPostVC1
        vc.isEdit = true
        vc.productItem = product
//        vc.selectedStoreId = product.store?.storeId!
//        vc.selectedCategoryId = (product.category?.id!)!
//        vc.selectedCategory2Id = product.subCategoryId!
//        vc.productName = product.name!
//        vc.productDescription = product.description!
//        vc.productPrice = product.price!
//        vc.productAmount = String(product.amount!)
//        vc.isSelectedRadio11 = product.propertyAll!
//        vc.isSelectedRadio12 = product.propertyRecent!
//        vc.isSelectedRadio13 = product.propertyActive!
//        vc.isSelectedPromotion0 = product.deliveryOnOff!
//        vc.isSelectedPromotion1 = product.refundOnOff!
//        vc.isSelectedPromotion2 = false
//        vc.isSelectedPromotion3 = product.refundInWeek!
//        vc.isSelectedPromotion4 = false
        
//        var customImageArray: [CustomImageModel] = []
//        for image in product.images! {
//            let url = URL(string: image)
//            if let imageData = try? Data(contentsOf: url!) {
//                let img: UIImage = UIImage(data: imageData)!
//
//                let customImage = CustomImageModel.init(imageURL: "imageUrl", image: img, isImage: true)
//                customImageArray.append(customImage)
//
//            }
//            
//        }
//        
//        vc.customImageArray = customImageArray
        
        myStoreProductManageVC.pushAndHideTabbar(vc)
    }
    
    @IBAction func selectDelete(_ sender: UIButton) {
        myStoreProductManageVC.presentAlert("你真的想删除吗?") {
            self.deleteProduct()
        }
    }
    
    private func deleteProduct() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查网络连接!")
            return
        }
        let parameters: [String : Any] = [
            "id" : product.id!
        ]
        MyAPI.shared.itemDelete(params: parameters) { (json, success) in
            if success {
                print("Item Delete...")
                print(json)
                DispatchQueue.main.async {
                    ProgressHUD.showSuccessWithStatus("成功删除!")
                    self.myStoreProductManageVC.products.remove(at: self.index)
                    if self.myStoreProductManageVC.products.count > 0 {
                        self.myStoreProductManageVC.noDataView.isHidden = true
                    } else {
                        self.myStoreProductManageVC.noDataView.isHidden = false
                    }
                    
                    self.deleteImagesFromAliyun()
                    
                }
            } else {
                // try again...
                MyAPI.shared.itemDelete(params: parameters, completion: { (json1, success1) in
                    if success1 {
                        DispatchQueue.main.async {
                            ProgressHUD.showSuccessWithStatus("成功删除!")
                            self.myStoreProductManageVC.products.remove(at: self.index)
                            if self.myStoreProductManageVC.products.count > 0 {
                                self.myStoreProductManageVC.noDataView.isHidden = true
                            } else {
                                self.myStoreProductManageVC.noDataView.isHidden = false
                            }
                            self.deleteImagesFromAliyun()
                        }
                    } else {
                        ProgressHUD.showErrorWithStatus("出了点问题，请重试.")
                    }
                })
            }
            
        }
    }
    
    private func deleteImagesFromAliyun() {
        let images = product.images!
        let objectKeys = Utils.getObjectKeysFromImageUrls(images)
        AliyunUtil.shared.deleteImages(objectKeys) { (results) in
            DispatchQueue.main.async {
                self.myStoreProductManageVC.collectionView.reloadData()
            }            
        }
        
        if product.qrimage! != "" {
            let objectKey = Utils.getObjectKeyFromImageUrl(product.qrimage!)
            AliyunUtil.shared.deleteImage(objectKey) { (result) in }
        }
    }
    
    private func activeProduct() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查网络连接!")
            return
        }
        let parameters: [String : Any] = [
            "id" : product.id!
        ]
        MyAPI.shared.itemActive(params: parameters) { (json, success) in
            if success {
                //print("Item Active...")
                //print(json)
                ProgressHUD.showSuccessWithStatus("成功上架!")
                self.myStoreProductManageVC.products[self.index].status = 1
                self.myStoreProductManageVC.products[self.index].active = true
                self.product.status = 1
                self.product.active = true
                self.stateButton.setImage(ImageAsset.my_store_download.image, for: .normal)
                self.stateLabel.text = "上架"
            } else {
                // try again...
                MyAPI.shared.itemActive(params: parameters, completion: { (json, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功上架!")
                        self.myStoreProductManageVC.products[self.index].status = 1
                        self.myStoreProductManageVC.products[self.index].active = true
                        self.product.status = 1
                        self.product.active = true
                        self.stateButton.setImage(ImageAsset.my_store_download.image, for: .normal)
                        self.stateLabel.text = "上架"
                    } else {
                        ProgressHUD.showErrorWithStatus("出了点问题，请重试.")
                    }
                })
            }
        }
    }
    
    private func inactiveProduct() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查网络连接!")
            return
        }
        let parameters: [String : Any] = [
            "id" : product.id!
        ]
        MyAPI.shared.itemInactive(params: parameters) { (json, success) in
            if success {
                //print("Item Inactive...")
                //print(json)
                ProgressHUD.showSuccessWithStatus("成功未上架!")
                self.myStoreProductManageVC.products[self.index].status = 0
                self.myStoreProductManageVC.products[self.index].active = false
                self.product.status = 0
                self.product.active = false
                self.stateButton.setImage(ImageAsset.my_store_upload.image, for: .normal)
                self.stateLabel.text = "未上架"
            } else {
                // try again...
                MyAPI.shared.itemInactive(params: parameters, completion: { (json, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功未上架!")
                        self.myStoreProductManageVC.products[self.index].status = 0
                        self.myStoreProductManageVC.products[self.index].active = false
                        self.product.status = 0
                        self.product.active = false
                        self.stateButton.setImage(ImageAsset.my_store_upload.image, for: .normal)
                        self.stateLabel.text = "未上架"
                    } else {
                        ProgressHUD.showErrorWithStatus("出了点问题，请重试.")
                    }
                })                
            }
        }
    }
    
    @objc func tapProductImageView() {
        var images = [SKPhoto]()
        for imageUrl in product.images! {
            let photo = SKPhoto.photoWithImageURL(imageUrl, holder: nil)//SKPhoto.photoWithImageURL(API.IMAGE_URL + imageUrl, holder: nil)
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: 0)
        myStoreProductManageVC.present(browser, animated: true) { }
    }
    
    
}





