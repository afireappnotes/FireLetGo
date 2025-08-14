import UIKit
import SwiftUI
import SwiftData

final class SwiftUIRootViewController: UIViewController {
    private var hostingController: UIHostingController<AnyView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdsControllerService.share.notShowBanner = false
        AdsControllerService.share.getOneAd()
        
        view.backgroundColor = .systemBackground
        overrideUserInterfaceStyle = .dark
        attachSwiftUI()
    }
    
    private func attachSwiftUI() {
        do {
            let modelContainer = try ModelContainer(for: Note.self)
            let rootView = ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
            let hosting = UIHostingController(rootView: AnyView(rootView))
            hosting.overrideUserInterfaceStyle = .dark
            addChild(hosting)
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hosting.view)
            NSLayoutConstraint.activate([
                hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            hosting.didMove(toParent: self)
            self.hostingController = hosting
        } catch {
            assertionFailure("Failed to create ModelContainer: \(error)")
        }
    }
} 
