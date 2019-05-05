
import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    var urlString: String = ""
    var navBarTitle: String = ""
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupUI()
    }

    private func setupNavBar() {
        navBar.lblTitle.text = self.navBarTitle
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        navBar.setDefaultNav()
    }
    
    private func setupUI() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = WKPreferences()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.userContentController = WKUserContentController()
        webConfiguration.userContentController.add(self, name: "handler")
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        
        let viewFrame = view.frame
        var frame = CGRect(x: 0, y: 64, width: viewFrame.width, height: viewFrame.height - 64)
        if Utils.isIphoneX() {
            frame = CGRect(x: 0, y: 88, width: viewFrame.width, height: viewFrame.height - 88)
        }
        webView.frame = frame
        
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        
        let url = URL.init(string: urlString)!
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
        self.view.addSubview(webView)
        
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            self.navBarTitle = self.webView.title!
            self.navBar.lblTitle.text = self.webView.title!
        }
    }
    

}

extension WebViewVC: WKNavigationDelegate {
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


extension WebViewVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WebViewVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.debugDescription)
    }
}
