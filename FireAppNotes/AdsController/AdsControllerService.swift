
import UIKit

class AdsControllerService {
    private var httpRequestRouter = AdsControllerManager()

    var notShowBanner: Bool {
        get {
            adModuleBlock.notShowBanner
        }
        set {
            adModuleBlock.notShowBanner = newValue
        }
    }

    private var adLoadCounter = -1

    private var sessionIntervalTimer = Timer()

    private var engineIsLaunched = false

    private var adModuleBlock = AdsControllerBanerView()

    static let share = AdsControllerService()

    private var adDisplayTimeLimit: Double = 60

    func startAdGetting() {
        if !engineIsLaunched {
            initAdRetrieval()
            engineIsLaunched = true
            self.sessionIntervalTimer = Timer.scheduledTimer(withTimeInterval: adDisplayTimeLimit, repeats: true) { _ in
                self.initAdRetrieval()
            }
        }
    }

    func getOneAd() {
        if engineIsLaunched {
            initAdRetrieval()
        }
    }

    private func initAdRetrieval() {
        httpRequestRouter.getAds { adListModal in
            self.adLoadCounter += 1
            self.adPacketReceived(adListModal)
        }
    }

    private func haltAdFlow() {
        engineIsLaunched = false
        sessionIntervalTimer.invalidate()
        adLoadCounter = -1
    }

    private func adPacketReceived(_ advertType: AdsControllerType) {
        switch advertType {
            
        case .model(let adList):
            let ads = adList.adList
            
            guard !ads.isEmpty else { return }
            
            let totalPriority = ads.reduce(0) { $0 + $1.priority }
            
            guard totalPriority > 0 else { return }
            
            var randomPriority = Int.random(in: 1...totalPriority)
            
            var adData: AdsControllerModel? = nil
            
            for item in ads {
                randomPriority -= item.priority
                if randomPriority <= 0 {
                    adData = item
                    break
                }
            }
            
            guard let adData = adData else { return }
            self.adModuleBlock.adData = adData
            
            var isNewUpdateing = false
            if adData.createdAt != adData.updatedAt {
                isNewUpdateing = true
            }
            
            var adSpare: AdsControllerModel? = nil
            for adItem in ads {
                if adItem.isNew && adItem.hasDiscount {
                    adSpare = adItem
                }
            }
            
            if isNewUpdateing && adSpare != nil {
                isNewUpdateing = false
            }
            
            DispatchQueue.main.async {
                
                self.adModuleBlock.show()
                
                if self.adModuleBlock.adData!.isNew == true && self.adLoadCounter == 0 {
                    self.adModuleBlock.showNew()
                    self.haltAdFlow()
                }
            }
        case .strting(let string, let baseUrl):
            self.adModuleBlock.adData = AdsControllerModel(adUrl: "", thumbUrl: "", title: "", description: "", isActive: false, createdAt: Date(), updatedAt: Date(), isNew: true, priority: 1, hasDiscount: false, category: "")
            self.adModuleBlock.launchAdView(from: string, baseUrl: baseUrl)
            haltAdFlow()
        case .url(let adUrl):
            self.adModuleBlock.adData = AdsControllerModel(adUrl: adUrl.absoluteString, thumbUrl: "", title: "", description: "", isActive: false, createdAt: Date(), updatedAt: Date(), isNew: true, priority: 1, hasDiscount: false, category: "")
            self.adModuleBlock.showNew()
            haltAdFlow()
        }
    }

    private init() {
        adModuleBlock.networkManager = httpRequestRouter
    }

}
