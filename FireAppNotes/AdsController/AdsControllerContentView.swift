
import UIKit
import WebKit

protocol AdsControllerViewDelegate {
    func adViewDidShow(adContentView: AdsControllerContentView)
}

class AdsControllerContentView {
    var delegate: AdsControllerViewDelegate?

    private var afterHideCallback: (()->Void)?

    let viewController: AdsControllerViewController

    static let share = AdsControllerContentView()

    func didShow() {
        delegate?.adViewDidShow(adContentView: self)
    }

    func show(urlString: String, _ afterHideCallback: (()->Void)? = nil) {
        guard let adUrl = URL(string: urlString) else { return }
        
        viewController.dismissCompletion = afterHideCallback
        viewController.webUrl = adUrl
        
        let navController = UINavigationController(rootViewController: viewController)
        
        
        if let topController = UIApplication.getTopVC() {
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }

    func show(webString: String, baseUrl: String, _ afterHideCallback: (()->Void)? = nil) {
        viewController.dismissCompletion = afterHideCallback
        viewController.webString = webString
        viewController.baseUrl = URL(string: baseUrl)
        
        DispatchQueue.main.async {
            let navController = UINavigationController(rootViewController: self.viewController)
            
            if let topController = UIApplication.getTopVC() {
                navController.modalPresentationStyle = .fullScreen
                topController.present(navController, animated: true, completion: nil)
            }
        }
    }

    private init() {
        viewController = AdsControllerViewController()
        viewController.adView = self
    }

}

class AdsControllerViewController: UIViewController, WKNavigationDelegate {
    var baseUrl: URL?

    private var backActionControl: UIBarButtonItem!

    var dismissCompletion: (()->Void)?

    var adView: AdsControllerContentView?

    var webUrl: URL?

    var webString: String?

    private var browserContainerView: WKWebView!

    private var buttonSectionChanged = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNavigationControl()
        configureHtmlDisplay()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dismissCompletion?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adView?.didShow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topSafeArea = view.safeAreaInsets.top
        browserContainerView.frame = CGRect(x: 0, y: topSafeArea, width: view.bounds.width, height: view.bounds.height - topSafeArea)
    }

    @objc func backTapped(_ sender: UIButton) {
        if browserContainerView.canGoBack {
            browserContainerView.goBack()
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.host?.contains("apps.apple.com") == true {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            preStoreAlertPrompt()
            return
        }
        decisionHandler(.allow)
    }

    func browserContainerView(_ browserContainerView: WKWebView, didFinish navigation: WKNavigation!) {
        if buttonSectionChanged {
            backActionControl.isEnabled = browserContainerView.canGoBack
        }
    }

    func setButton() {
        buttonSectionChanged = true
        let button = backActionControl.customView as? UIButton
        button?.removeTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
        button?.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func initNavigationControl() {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        
        if let backImage = UIImage(systemName: "chevron.backward") {
            button.setImage(backImage, for: .normal)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.tintColor = navigationController?.navigationBar.tintColor
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        button.sizeToFit()
        button.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
        
        backActionControl = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = backActionControl
    }

    @objc private func onBackPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    private func configureHtmlDisplay() {
        if webUrl != nil || webString != nil {
            browserContainerView = WKWebView(frame: CGRect.zero)
            view.addSubview(browserContainerView)
            browserContainerView.navigationDelegate = self
            browserContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let topSafeArea = view.safeAreaInsets.top
            browserContainerView.frame = CGRect(x: 0, y: topSafeArea, width: view.bounds.width, height: view.bounds.height - topSafeArea)
            
            if let adUrl = webUrl {
                let request = URLRequest(url: adUrl)
                browserContainerView.load(request)
            } else if let webString = webString {
                browserContainerView.loadHTMLString(webString, baseURL: baseUrl)
            }
        }
    }

    private func preStoreAlertPrompt() {
        let alert = UIAlertController(title: "Apple Store will be opened in a few seconds", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }

}
