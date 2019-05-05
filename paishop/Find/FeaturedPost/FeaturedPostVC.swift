//
//  FeaturedPostVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class FeaturedPostVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FeaturedPostCollectionViewCellDelegate {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postBtnBackViewHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(FeaturedPostImageCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.isEditing = true
        }
    }
    
    @IBOutlet weak var collectionListView: UICollectionView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeightConstraint.constant = 0
        }
    }
    
    @IBOutlet weak var postButton: RoundRectButton!
    @IBOutlet weak var postButtonBg: GradientView!
    @IBOutlet weak var insertBackView: UIView! {
        didSet {
            insertBackView.isHidden = true
        }
    }
    @IBOutlet weak var insertFuncView: UIView! {
        didSet {
            insertFuncView.isHidden = true
        }
    }
    
    var customImageArray: [CustomImageModel] = []
    var deletedImages: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupTheme()
        setupUI()
        self.initMainView()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "发动态"//"发布文章"
        navBar.setDefaultNav()
        navBar.delegate = self
        if Utils.isIphoneX() {
            postBtnBackViewHConstraint.constant = 88
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        
        postButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        postButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func setupUI() {
        descriptionTextView.placeholder = "请输入文章内容"
    }
    
    private func initMainView() {
        collectionListView.delegate = self
        collectionListView.dataSource = self
        collectionListView.alwaysBounceVertical = true
        collectionListView.isScrollEnabled = true
        collectionListView.allowsSelection = false
        collectionListView.register(UINib.init(nibName: "FeaturedPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeaturedPostCollectionViewCell")
        self.automaticallyAdjustsScrollViewInsets = true
        
        
    }
    
    @IBAction func selectImages(_ sender: UIButton) {

    }
    
    private func closeViews() {
        insertBackView.isHidden = true
        insertFuncView.isHidden = true
    }
    
    @IBAction func closeInsertView(_ sender: UIButton) {
        closeViews()
    }
    
    @IBAction func insertCameraImg(_ sender: UIButton) {
        closeViews()
        self.selectCameraImage()
    }
    
    @IBAction func insertCameraVideo(_ sender: UIButton) {
        closeViews()
        self.selectCameraVideo()
    }
    
    @IBAction func insertAlbumImg(_ sender: UIButton) {
        closeViews()
        self.selectLibrary()
    }
    
    @IBAction func postContent(_ sender: UIButton) {
        if !validateFields() {
            return
        }
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        self.postImageArray()
    }
    
    
    @IBAction func selectPost(_ sender: UIButton) {
        if !validateFields() {
            return
        }
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        self.postImageArray()
    }
    
    
    
    private func selectLibrary() {
        let maxNumber = 6 - self.customImageArray.count
        
        self.presentImagePickerController(
            maxNumberOfSelections: maxNumber,
            select: { (asset: PHAsset) -> Void in
                print("FeaturedPostVC Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("FeaturedPostVC Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("FeaturedPostVC Cancel: \(assets)")
        }, finish: {[weak self] (assets: [PHAsset]) -> Void in
            print("FeaturedPostVC Finish: \(assets[0])")
            for asset in assets {
                if let image = asset.getUIImage() {
                    let imageUrl = "imageUrl"
                    let customImage = CustomImageModel.init(imageURL: imageUrl, image: image, isImage: true)
                    self?.customImageArray.append(customImage)
                    
                }
            }
            DispatchQueue.main.async {
                self?.updateTableViewHeight()
            }
            
            }, completion: { () -> Void in
                print("FeaturedPostVC  completion")
        })
    }
    
    private func selectCameraImage() {
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
    
    private func selectCameraVideo() {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
                if !granted {
                    self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
                } else {
                    let mediaPicker =  UIImagePickerController()
                    mediaPicker.delegate = self
                    mediaPicker.sourceType = .camera
                    mediaPicker.mediaTypes = NSArray.init(object: kUTTypeMovie) as! [String]
                    mediaPicker.videoMaximumDuration = 60.0 // 60s
                    mediaPicker.videoQuality = .typeMedium
                    self.present(mediaPicker, animated: true, completion: nil)
                }
            })
        } else if authStatus == .restricted || authStatus == .denied {
            self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
        } else if authStatus == .authorized {
            let mediaPicker =  UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.sourceType = .camera
            mediaPicker.mediaTypes = NSArray.init(object: kUTTypeMovie) as! [String]
            mediaPicker.videoMaximumDuration = 60.0 // 60s
            mediaPicker.videoQuality = .typeMedium
            self.present(mediaPicker, animated: true, completion: nil)
        }
        
    }
    
    
    
    func updateTableViewHeight() {
        collectionListView.reloadData()
        /*
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
 */
        
        collectionListView.reloadData()
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
    
    func postImageArray() {
        var imageNames = [String](repeatElement("", count: self.customImageArray.count))
        var objectKeys = [String]()
        var images = [UIImage]()
        var imageURLs = [String]()
        var isImages = [Bool]()
        
        postButton.isEnabled = false
        ProgressHUD.showWithStatus()
        for i in 0..<customImageArray.count {
            let customImage = customImageArray[i]
            
            if customImage.isImage {
                let width = Int(customImage.image!.size.width)
                let height = Int(customImage.image!.size.height)
                let sufix = "_\(width)x\(height).jpg"
                let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
                
                let objectKey = Constants.ARTICLE + "/\(UserInstance.userId!)/" + "\(timestamp)" + sufix
                
                imageNames[i] = Constants.ALIYUN_URL_PREFIX + objectKey
                
                objectKeys.append(objectKey)
                images.append(customImage.image!)
                imageURLs.append(customImage.imageURL!)
                isImages.append(customImage.isImage!)
                
            } else { // video
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
            AliyunUtil.shared.putImages(images, objectKeys: objectKeys, imageUrls: imageURLs, isImages: isImages) { (results) in
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
                
//                self.postButton.isEnabled = true
                if imageNames.count < 3 {
                    // images upload error
                    ProgressHUD.dismiss()
                    self.postButton.isEnabled = true
                    ProgressHUD.showErrorWithStatus("商品图片上传错误")
                    return
                }
                
                // call product post or update api
                self.featuredPost(imageNames: imageNames)
            }
        } else {
            // call product post or update api
            featuredPost(imageNames: imageNames)
        }
    }
    
    private func validateFields() -> Bool {
        let description = descriptionTextView.text!
        if description.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入详情.")
            return false
        }
        if customImageArray.count < 3 {
            ProgressHUD.showWarningWithStatus("请选择3张以上的图片.")
            return false
        }
        
        return true
    }
    
    private func resetFields() {
        descriptionTextView.text = ""
        customImageArray = []
    }
    
    private func featuredPost(imageNames: [String]) {
        DispatchQueue.main.async {

            var arrayName = [String]()
            
            for imageName in imageNames {
                var strType = String()
                
                if imageName.contains(".jpg") == true {
                    strType = "\"type\": 0}"
                } else {
                    strType = "\"type\": 1}"
                }

                let str = "{\"url\": \"" + imageName + "\", " + strType
                arrayName.append(str)
                
            }
            
            
            let description = self.descriptionTextView.text!
            let featured_images = "[" + (arrayName.map{$0}).joined(separator: ", ") + "]"
            
            print(">>>> featured_images:\n", featured_images)
            
            let parameters: [String : Any] = [
                "text" : description,
                "images" : featured_images
            ]
            
            FindAPI.shared.postCreate(params: parameters, completion: { (json, success) in
                ProgressHUD.dismiss()
                self.postButton.isEnabled = true
                if success {
                    print("Post Create...", json)
                    self.resetFields()
                    ProgressHUD.showSuccessWithStatus("成功")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    let errors = json["errors"].dictionaryValue
                    if let error = errors.values.first {
                        if let firstError =  error.arrayObject?.first as? String {
                            ProgressHUD.showErrorWithStatus(firstError)
                        } else {
                            ProgressHUD.showErrorWithStatus("失败.")
                        }
                    } else {
                        ProgressHUD.showErrorWithStatus("失败.")
                    }
                }
            })
            
        }
    }
 
    
    // collection view datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedPostCollectionViewCell", for: indexPath) as! FeaturedPostCollectionViewCell
        cell.delegate = self
   
        if customImageArray.count == 0 {
            cell.setAdd()
            
        } else {
            if indexPath.row == customImageArray.count {
                cell.setAdd()
            } else {
                cell.index = indexPath.row
                cell.setInfo(model: self.customImageArray[indexPath.row])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionListView.bounds.size.width
        
        let wi = (collectionWidth - 10 * 4) / 3
        let he = wi
        
        return CGSize(width: wi, height: he)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    // MARK: - FeaturedPostCollectionViewCell delegate
    func didTapButtonFeaturedPostCollectionViewCell(index: NSInteger) {
        customImageArray.remove(at: index)
        collectionListView.reloadData()
    }
    
    func didTapButtonFeaturedPostCollectionViewCellAdd() {
        insertBackView.isHidden = false
        insertFuncView.isHidden = false
        
        UIView.animate(withDuration: 2.3, delay: 0, usingSpringWithDamping: 0.53, initialSpringVelocity: 0, options: .curveEaseOut, animations: { self.view.layoutSubviews() }, completion: nil)

    }

}


extension FeaturedPostVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension FeaturedPostVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        
        // photo
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                let imageUrl = "imageUrl"
                let customImage = CustomImageModel.init(imageURL: imageUrl, image: image, isImage: true)
                self.customImageArray.append(customImage)
                self.updateTableViewHeight()
            }
        
        // video
        } else if mediaType.isEqual(to: kUTTypeMovie as String) {
            guard let videoUrl: NSURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else { return }
            if picker.sourceType == .camera {
                
                // get thumbnail from local video file
                do {
                    let asset = AVURLAsset(url: videoUrl as URL, options: nil)
                    let imageGen = AVAssetImageGenerator(asset: asset)
                    let cgImage = try imageGen.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)

                    let uiImage = UIImage(cgImage: cgImage)
                    
                    let customImage = CustomImageModel.init(imageURL: videoUrl.absoluteString, image: uiImage, isImage: false)
                    self.customImageArray.append(customImage)
                    self.updateTableViewHeight()
                    
                } catch let error {
                    print(">>> error:", error.localizedDescription)
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//extension FeaturedPostVC: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.customImageArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: FeaturedPostImageCell = tableView.ts_dequeueReusableCell(FeaturedPostImageCell.self)
//        cell.setCellContent(self.customImageArray[indexPath.row], index: indexPath.row, vc: self)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let moveImage = self.customImageArray[sourceIndexPath.row]
//        self.customImageArray.remove(at: sourceIndexPath.row)
//        self.customImageArray.insert(moveImage, at: destinationIndexPath.row)
//
//        self.tableView.ts_reloadData {  }
//    }
    
//}















