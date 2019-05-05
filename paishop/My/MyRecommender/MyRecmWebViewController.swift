//
//  MyRecmWebViewController.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/16.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyRecmWebViewController: UIViewController, NavBarDelegate, UIWebViewDelegate {

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myWebView: UIWebView!
    
    var index = NSInteger()
    var transfer_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupNavBar()
        self.loadWebView(index: index)
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
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    func loadWebView(index: NSInteger) {
        var strTitle = ""
        let mainUrl = "http://api.pi-world.net/"
        let mainUrl1 = "http://www.pi-world.net/"
        
        let subAddr3 = "gpqq"
        let subAddr4 = "cshhr"
        let subAddr5 = "hhr_z"
        let subAddr6 = "stores_exchage"
        let subAddr7 = "public/webshare/"
        let subAddr8 = "event/main"
        let subAddr9 = "api_test/deliveries.php?type=mobile&id="
        
        //let token = UserInstance.deviceToken!
        let userID = String(UserInstance.userId!)
        var strUrl = String()
        
        if index == 3 {
            strTitle = "股票期权"
            //strUrl = mainUrl + subAddr3 + "?token_id=" + token
            strUrl = mainUrl + subAddr3 + "?token_id=" + userID + "&device=2"
            
        } else if index == 4 {
            strTitle = "城市合伙人"
            //strUrl = mainUrl + subAddr4 + "?token_id=" + token
            strUrl = mainUrl + subAddr4 + "?token_id=" + userID + "&device=2"
            
        } else if index == 5 {
            strTitle = "提现"
            //strUrl = mainUrl + subAddr5 + "?token_id=" + token
            strUrl = mainUrl + subAddr5 + "?token_id=" + userID + "&device=2"
            
        } else if index == 6 {
            strTitle = "提现"
            //strUrl = mainUrl + subAddr6 + "?token_id=" + token
            strUrl = mainUrl + subAddr6 + "?token_id=" + userID + "&device=2"
        } else if index == 7 {
            strTitle = "二维码分享"
            strUrl = mainUrl1 + subAddr7 + "?uid=" + String(UserInstance.userId!)
        } else if index == 8 {
            strTitle = "活动中心"
            strUrl = mainUrl1 + subAddr8 + "?uid=" + String(UserInstance.userId!)
        } else if index == 9 {
            strTitle = "快递查询"
            strUrl = mainUrl1 + subAddr9 + transfer_id
        }
        
        print(">>>> strUrl:\n", strUrl)
        
        navBar.lblTitle.text = strTitle
        
        myWebView.delegate = self

        ProgressHUD.showWithStatus()
        myWebView.loadRequest(NSURLRequest(url: URL(string: strUrl)!) as URLRequest)

    }
    
    // MARK: - UIWebView delegate
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ProgressHUD.showErrorWithStatus(error.localizedDescription)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ProgressHUD.dismiss()
    }
    
    // MARK: NabBar delegate
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
