

import UIKit
import WebKit

class AboutUsVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewFrame: UIView!
    
    var webView: WKWebView!
    let aboutUsUrlString = API.HOST + "/aboutus"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = WKPreferences()
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        
        let viewFrame = view.frame
        var frame = CGRect(x: 0, y: 64, width: viewFrame.width, height: viewFrame.height - 64)
        if Utils.isIphoneX() {
           frame = CGRect(x: 0, y: 88, width: viewFrame.width, height: viewFrame.height - 88)
        }
        webView.frame = frame
        
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        
        let url = URL.init(string: aboutUsUrlString)!
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
        self.view.addSubview(webView)
        
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "服务介绍"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }

}


extension AboutUsVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation){
        ProgressHUD.showWithStatus()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)){
        decisionHandler(.allow)
    }
}


extension AboutUsVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}




