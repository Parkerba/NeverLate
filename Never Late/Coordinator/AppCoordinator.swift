import UIKit

// MARK: - Protocol
protocol ChildCoordinatable {
    var rootViewController: NeverLateEntryViewController { get }
    var appCoordinator: AppCoordinator { get }

    func start()
}

// MARK: - Class
final class AppCoordinator : EventReciever {
    
    func recieveEvent(event: Event) {
        rootViewController.addEvent(event: event)
        rootViewController.dismiss(animated: true, completion: nil)
        rootViewController.eventTable.reloadData()
    }
    
    // MARK: Enum
    enum AppError: LocalizedError {
        case custom(String)
        
        var errorDescription: String? {
            switch self {
            case .custom(let message):
                return message
            }
        }
    }
    
    // MARK: Properties
    private(set) var rootViewController: NeverLateEntryViewController
    private var childCoordinators: [ChildCoordinatable] = []
    
    // MARK: Life Cycle
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController.viewControllers.first as! NeverLateEntryViewController
    }
    
    public func showAddEvent() {
        let vc = AddNewViewController()
        vc.delegate = self
        rootViewController.present(vc, animated: true, completion: nil)
    }
    func start() {
        rootViewController.addNewEntry = {
            self.showAddEvent()
        }
    }
}
