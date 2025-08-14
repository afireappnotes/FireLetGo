//
//  AppDelegate.swift
//  FireAppNotes
//
//  Created by vo on 14.08.2025.
//

import UIKit
import OneSignalFramework
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setOneSignal(with: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        cofigureAppsFluer()
        
        return true
    }
    @objc func initAppsflyer() {
        AppsFlyerLib.shared().start()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notificationInfo = response.notification.request.content.userInfo
        
        if let customData = notificationInfo["custom"] as? [AnyHashable: Any], let notificationBody = customData["u"] as? String {
            notifySystem(notificationBody: notificationBody)
        }
        
        completionHandler()
    }

    private func notifySystem(notificationBody: String) {
        NotificationCenter.default.post(name: .pushArrived, object: nil, userInfo: ["notificationBody": notificationBody])
    }
}

extension AppDelegate {

    func setOneSignal(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        
        OneSignal.initialize(GlobalConfig.oneSignalPushServiceId, withLaunchOptions: options)
          OneSignal.Notifications.requestPermission({ userConsent in
            print("Notification consent granted by user: \(userConsent)")
          }, fallbackToSettings: true)
        
    }

}

extension AppDelegate {
    
    func cofigureAppsFluer() {
        AppsFlyerLib.shared().appsFlyerDevKey = GlobalConfig.afApiKey
        AppsFlyerLib.shared().appleAppID = GlobalConfig.applicationIdentifier
        AppsFlyerLib.shared().customerUserID = AppsFlyerLib.shared().getAppsFlyerUID()
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 90)
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("initAppsflyer"), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}
