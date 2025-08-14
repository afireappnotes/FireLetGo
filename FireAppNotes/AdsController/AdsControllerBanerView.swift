
import Foundation
import UIKit

class AdsControllerBanerView: UIView {
    private let adWrapperView = AdsControllerContentView.share

    var networkManager: AdsControllerManager?

    private var promoGraphic: UIImage? = UIImage(named: "banner_empty") {
        didSet {
            DispatchQueue.main.async {
                self.promoMediaHolder.image = self.promoGraphic
            }
        }
    }

    var notShowBanner = true

    private var promoMediaHolder: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let closeIconControl: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .link
        button.addTarget(self, action: #selector(handleCloseIcon), for: .touchUpInside)
        button.backgroundColor = .white.withAlphaComponent(0.4)
        button.layer.cornerRadius = 5
        return button
    }()

    var adData: AdsControllerModel? = nil {
        didSet {
            if let imageUrlString = adData?.thumbUrl {
                networkManager?.getImage(urlString: imageUrlString) { img in
                    self.promoGraphic = img
                }
            }
        }
    }

    private var adRecentlyVisible = false

    private let adLayoutHeight: CGFloat = 40

    private var adIsVisibleNow = false

    private let adLayoutWidth: CGFloat = 300

    func show() {
        guard notShowBanner == false else { return }
        guard adData != nil else { return }
        guard adData?.isNew == false else { return }
        guard let parentVC = UIApplication.getTopVC() else { return }
        guard (parentVC as? UIAlertController) == nil else { return }
        
        if !adIsVisibleNow {
            if isAppeared {
                if self.superview !== parentVC.view {
                    shutdownAdDisplay() {
                        self.displayAdLayout(in: parentVC.view )
                    }
                }
            } else {
                self.displayAdLayout(in: parentVC.view )
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adWrapperView.delegate = self
        prepareVisualBlock()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBannerPressed)))
    }

    func showNew() {
        adRecentlyVisible = true
        launchAdView()
    }

    func launchAdView(from string: String, baseUrl: String) {
        adIsVisibleNow = true
        adWrapperView.show(webString: string, baseUrl: baseUrl) {
            self.adIsVisibleNow = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareVisualBlock() {
        
        self.clipsToBounds = true
        self.backgroundColor = .green
        self.layer.cornerRadius = 3
        
        self.addSubview(promoMediaHolder)
        
        promoMediaHolder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            promoMediaHolder.topAnchor.constraint(equalTo: self.topAnchor),
            promoMediaHolder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            promoMediaHolder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            promoMediaHolder.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        self.addSubview(closeIconControl)
        
        closeIconControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeIconControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            closeIconControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            closeIconControl.widthAnchor.constraint(equalToConstant: 30),
            closeIconControl.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownReaction))
        swipeDownGesture.direction = .down
        self.addGestureRecognizer(swipeDownGesture)
    }

    private func resolveAdUri() -> String? {
        guard let adUrl = adData?.adUrl else { return nil }
        if !adRecentlyVisible {
            return adUrl
        } else {
            adRecentlyVisible = false
            return adUrl.addParamsToURL(params: networkManager?.newDataPrm() ?? "")
        }
    }

    @objc private func onBannerPressed() {
        launchAdView()
    }

    @objc private func handleCloseIcon() {
        shutdownAdDisplay()
    }

    private func shutdownAdDisplay(_ completion: (()->Void)? = nil) {
        if let superview = superview {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame = CGRect(x: self.frame.origin.x,
                                    y: superview.frame.height,
                                    width: self.frame.width,
                                    height: self.frame.height)
            }) { _ in
                self.removeFromSuperview()
                self.isAppeared = false
                completion?()
            }
        } else {
            self.isAppeared = false
            completion?()
        }
    }

    @objc private func swipeDownReaction() {
        shutdownAdDisplay()
    }

    private func displayAdLayout(in parentView: UIView) {
        promoMediaHolder.image = promoGraphic
        let safeAreaBottom = parentView.safeAreaInsets.bottom

        self.frame = CGRect(x: (parentView.frame.width - adLayoutWidth) / 2,
                            y: parentView.frame.height,
                            width: adLayoutWidth,
                            height: adLayoutHeight)

        parentView.addSubview(self)

        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.frame = CGRect(x: (parentView.frame.width - adLayoutWidth) / 2,
                                y: parentView.frame.height - adLayoutHeight - safeAreaBottom - 5, // высота на которую поднимаеться банер
                                width: adLayoutWidth,
                                height: adLayoutHeight)
        }) { _ in
            self.isAppeared = true
        }
    }

    private func launchAdView() {
        guard let adUrl = resolveAdUri() else { return }
        adIsVisibleNow = true
        adWrapperView.show(urlString: adUrl) {
            self.adIsVisibleNow = false
        }
    }

    private(set) var isAppeared = false
    
}

extension AdsControllerBanerView: AdsControllerViewDelegate {
    func adViewDidShow(adContentView: AdsControllerContentView) {
        guard adData?.isNew == true else { return }
        adWrapperView.viewController.setButton()
    }

}
