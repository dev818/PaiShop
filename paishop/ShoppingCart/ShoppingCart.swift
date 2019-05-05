
import UIKit
import WebKit

class ShoppingCart: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navFrame: UIView!
    @IBOutlet weak var navFrameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var webViewContainer: UIView!
    
    var webView: WKWebView!
    var isLoadingWebView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = WKPreferences()
        
        var frame = self.view.frame
        if Utils.isIpad() {
            frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 49)
        }
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        
        self.view.addSubview(webView)
        
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserInstance.isLogin {
            let urlString = API.WEB_LINK + "/game_api/loading.php?user=\(UserInstance.userId!)&key=" + UserInstance.deviceToken!
            webView.isHidden = true
            self.isLoadingWebView = true
            let url = URL.init(string: urlString)!
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
            titleLabel.text = urlString
        } else {
            webView.isHidden = true
            goToLoginVC()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.isLoadingWebView = false
    }
    
    @IBAction func selectBack(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    private func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    

}


extension ShoppingCart: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation){
        if self.isLoadingWebView {
            ProgressHUD.showWithStatus()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.isLoadingWebView {
            self.webView.isHidden = false
            ProgressHUD.dismiss()
            self.isLoadingWebView = false
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        backButton.isEnabled = webView.canGoBack
        
        titleLabel.text = webView.url?.absoluteString
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)){
        decisionHandler(.allow)
    }
}














