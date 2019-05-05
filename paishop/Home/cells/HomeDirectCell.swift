//
//  HomeDirectCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class HomeDirectCell: UITableViewCell {
    
    @IBOutlet weak var frame1: UIView!
    @IBOutlet weak var frame2: UIView!
    @IBOutlet weak var frame3: UIView!
    @IBOutlet weak var frame4: UIView!
    @IBOutlet weak var frame5: UIView!
    @IBOutlet weak var frame6: UIView!
    @IBOutlet weak var frame7: UIView!
    @IBOutlet weak var frame8: UIView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var nameLabel1: UILabel!
    @IBOutlet weak var descriptionLabel1: UILabel!
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var nameLabel2: UILabel!
    @IBOutlet weak var descriptionLabel2: UILabel!
    
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var nameLabel3: UILabel!
    @IBOutlet weak var descriptionLabel3: UILabel!
    
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var nameLabel4: UILabel!
    @IBOutlet weak var descriptionLabel4: UILabel!
    
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var nameLabel5: UILabel!
    @IBOutlet weak var descriptionLabel5: UILabel!
    
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var nameLabel6: UILabel!
    @IBOutlet weak var descriptionLabel6: UILabel!
    
    @IBOutlet weak var imageView7: UIImageView!
    @IBOutlet weak var nameLabel7: UILabel!
    @IBOutlet weak var descriptionLabel7: UILabel!
    
    @IBOutlet weak var imageView8: UIImageView!
    @IBOutlet weak var nameLabel8: UILabel!
    @IBOutlet weak var descriptionLabel8: UILabel!
    
    
    var parentVC: HomeVC!
    
    var product1: ProductListModel!
    var product2: ProductListModel!
    var product3: ProductListModel!
    var product4: ProductListModel!
    var product5: ProductListModel!
    var product6: ProductListModel!
    var product7: ProductListModel!
    var product8: ProductListModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCellContent(_ vc: HomeVC) {
        self.parentVC = vc
        product1 = vc.recommendDirects[0]
        if (product1.images?.count)! > 0 {
            self.imageView1.sd_setShowActivityIndicatorView(true)
            self.imageView1.sd_setIndicatorStyle(.gray)
            
            if let product1Url = product1.images?.first, product1Url != "" {
                let resizedProduct1Url = Utils.getResizedImageUrlString(product1Url, width: "200")
                self.imageView1.sd_setImage(with: URL(string: resizedProduct1Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel1.text = product1.name
        descriptionLabel1.text = product1.description
        
        product2 = vc.recommendDirects[1]
        if (product2.images?.count)! > 0 {
            self.imageView2.sd_setShowActivityIndicatorView(true)
            self.imageView2.sd_setIndicatorStyle(.gray)
            
            if let product2Url = product2.images?.first, product2Url != "" {
                let resizedProduct2Url = Utils.getResizedImageUrlString(product2Url, width: "200")
                self.imageView2.sd_setImage(with: URL(string: resizedProduct2Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel2.text = product2.name
        descriptionLabel2.text = product2.description
        
        product3 = vc.recommendDirects[2]
        if (product3.images?.count)! > 0 {
            self.imageView3.sd_setShowActivityIndicatorView(true)
            self.imageView3.sd_setIndicatorStyle(.gray)
            
            if let product3Url = product3.images?.first, product3Url != "" {
                let resizedProduct3Url = Utils.getResizedImageUrlString(product3Url, width: "200")
                self.imageView3.sd_setImage(with: URL(string: resizedProduct3Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel3.text = product3.name
        descriptionLabel3.text = product3.description
        
        product4 = vc.recommendDirects[3]
        if (product4.images?.count)! > 0 {
            self.imageView4.sd_setShowActivityIndicatorView(true)
            self.imageView4.sd_setIndicatorStyle(.gray)
            
            if let product4Url = product4.images?.first, product4Url != "" {
                let resizedProduct4Url = Utils.getResizedImageUrlString(product4Url, width: "200")
                self.imageView4.sd_setImage(with: URL(string: resizedProduct4Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel4.text = product4.name
        descriptionLabel4.text = product4.description
        
        product5 = vc.recommendDirects[4]
        if (product5.images?.count)! > 0 {
            self.imageView5.sd_setShowActivityIndicatorView(true)
            self.imageView5.sd_setIndicatorStyle(.gray)
            
            if let product5Url = product5.images?.first, product5Url != "" {
                let resizedProduct5Url = Utils.getResizedImageUrlString(product5Url, width: "200")
                self.imageView5.sd_setImage(with: URL(string: resizedProduct5Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel5.text = product5.name
        descriptionLabel5.text = product5.description
        
        if vc.recommendDirects.count < 6 {
            frame6.isHidden = true
            return
        }
        frame6.isHidden = false
        product6 = vc.recommendDirects[5]
        if (product6.images?.count)! > 0 {
            self.imageView6.sd_setShowActivityIndicatorView(true)
            self.imageView6.sd_setIndicatorStyle(.gray)
            
            if let product6Url = product6.images?.first, product6Url != "" {
                let resizedProduct6Url = Utils.getResizedImageUrlString(product6Url, width: "200")
                self.imageView6.sd_setImage(with: URL(string: resizedProduct6Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel6.text = product6.name
        descriptionLabel6.text = product6.description
        
        if vc.recommendDirects.count < 7 {
            frame7.isHidden = true
            return
        }
        frame7.isHidden = false
        product7 = vc.recommendDirects[6]
        if (product7.images?.count)! > 0 {
            self.imageView7.sd_setShowActivityIndicatorView(true)
            self.imageView7.sd_setIndicatorStyle(.gray)
            
            if let product7Url = product7.images?.first, product7Url != "" {
                let resizedProduct7Url = Utils.getResizedImageUrlString(product7Url, width: "200")
                self.imageView7.sd_setImage(with: URL(string: resizedProduct7Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel7.text = product7.name
        descriptionLabel7.text = product7.description
        
        if vc.recommendDirects.count < 8 {
            frame8.isHidden = true
            return
        }
        frame8.isHidden = false
        product8 = vc.recommendDirects[7]
        if (product8.images?.count)! > 0 {
            self.imageView8.sd_setShowActivityIndicatorView(true)
            self.imageView8.sd_setIndicatorStyle(.gray)
            
            if let product8Url = product8.images?.first, product8Url != "" {
                let resizedProduct8Url = Utils.getResizedImageUrlString(product8Url, width: "200")
                self.imageView8.sd_setImage(with: URL(string: resizedProduct8Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        nameLabel8.text = product8.name
        descriptionLabel8.text = product8.description
        
    }
    
    
    @IBAction func selectProduct1(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = product1.id!
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProduct2(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = product2.id!
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProduct3(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = product3.id!
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProduct4(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = product4.id!
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProduct5(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = product5.id!
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProduct6(_ sender: UIButton) {
        if product6 != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = product6.id!
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectProduct7(_ sender: UIButton) {
        if product7 != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = product7.id!
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectProduct8(_ sender: UIButton) {
        if product8 != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = product8.id!
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
}













