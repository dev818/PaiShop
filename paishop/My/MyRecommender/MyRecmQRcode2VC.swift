//
//  MyRecmQRcode2VC.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/01.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import QRCode

class MyRecmQRcode2VC: UIViewController {

    @IBOutlet weak var lblMyInviteId: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imgQR: UIImageView!
    
    var shareUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.intMainView()
        self.setQRCode()
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
    
    func intMainView() {
        var userId = String()
        
        if UserInstance.id != nil {
            userId = String(format: "%li", UserInstance.id!)
        } else {
            userId = ""
        }
        
        lblMyInviteId.text = userId
        
        btnCopy.layer.masksToBounds = true
        btnCopy.layer.cornerRadius = btnCopy.frame.size.height / 2
        
        btnShare.layer.masksToBounds = true
        btnShare.layer.cornerRadius = btnShare.frame.size.height / 2
     
        // shareUrl
        shareUrl = String(format: "http://paikepaifu.cn/aboutus?id=%@&device=2", userId)
    }
    
    func setQRCode() {
        let url = URL.init(string: shareUrl)
        let qrCode = QRCode(url!)
        
        if qrCode?.image != nil {
            imgQR.image = qrCode?.image
        }
        
    }
    
    @IBAction func taBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapBtnCopy(_ sender: Any) {
        if lblMyInviteId.text != nil {
            UIPasteboard.general.string = lblMyInviteId.text
            ProgressHUD.showSuccessWithStatus("复制成功!")
        }
    }
    
    @IBAction func tapBtnShare(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [shareUrl], applicationActivities: nil)

        self.present(activityController, animated: true, completion: nil)
        
    }
    
}
