import UIKit
import AppTrackingTransparency

class AppTrackingViewController: UIViewController {
    
    @IBAction func cotinueTapped1(_ sender: Any) {
        identifierForAdvertising()
    }
    
    func identifierForAdvertising() {
        if #available(iOS 14, *) {
            self.removeObserver()
            
            ATTrackingManager.requestTrackingAuthorization { status in
                
                switch status {
                case .authorized:
                    
                    print("Authorized")
                case .denied, .notDetermined, .restricted: print("Denied")
                @unknown default: print("Unknown")
                }
                
                if status == .denied,
                   ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    self.addObserver()
                    self.trackingBagTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in
                        self.removeObserver()
                        self.openWelcome()
                    }
                    return
                }
                
                self.openWelcome()
            }
        } else {
            self.openWelcome()
        }
    }
    
    private var isOpenedWelcome = false
    private weak var observer: NSObjectProtocol?
    private var trackingBagTimer: Timer?
    
    private func addObserver() {
        self.removeObserver()
        self.observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.identifierForAdvertising()
        }
    }
    
    private func openWelcome() {
        if !isOpenedWelcome {
            trackingBagTimer?.invalidate()
            isOpenedWelcome = true
            DispatchQueue.main.async {
                guard let welcomeVC = UIStoryboard(name:  "IntroStartViewController", bundle: nil).instantiateInitialViewController() else { return }
                welcomeVC.modalPresentationStyle = .fullScreen
                self.present(welcomeVC, animated: true)
            }
        }
    }

    private func removeObserver() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observer = nil
    }

}
