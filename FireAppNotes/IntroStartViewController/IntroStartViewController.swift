//
//  IntroStartViewController.swift
//  FireAppNotes
//
//  Created by vo on 14.08.2025.
//

import UIKit

class IntroStartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: .pushArrived, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AdsControllerService.share.startAdGetting()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            self.goToMaimHosting()
        }
    }
    
    private func goToMaimHosting() {
        let swiftUIRootViewController = SwiftUIRootViewController()
        swiftUIRootViewController.modalPresentationStyle = .fullScreen
        present(swiftUIRootViewController, animated: true)
    }
    
    @objc func receiveNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo, let notificationBody = userInfo["notificationBody"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.presentNotification(path: notificationBody)
            }
        }
    }
    
    private func presentNotification(path: String) {
        let vc = AdsControllerViewController()
        vc.webUrl = URL(string: path)
        let navController = UINavigationController(rootViewController: vc)
        
        if let topController = UIApplication.getTopVC() {
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }

}
