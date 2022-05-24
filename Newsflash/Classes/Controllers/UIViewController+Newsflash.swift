
import UIKit
//import Firebase

extension UIViewController {
    func appManager() -> NFAppManager {
        return NFAppManager.sharedManager
    }
    
    func requestManager() -> NFRequestManager {
        return NFRequestManager.sharedManager
    }
    
    func updateConstraintWithAnimate(_ animate: Bool = true) -> Void {
        if animate == true {
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (complete) in
                    
            })
        } else {
            updateViewConstraints()
        }
    }

    func showSimpleAlert(_ title: String?, message: String?, closeButton: String?, completion:(() -> Void)?) -> Void {
        let alertView = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction.init(title: closeButton, style: .cancel) { (alertAction: UIAlertAction) in
            if completion != nil {
                completion!()
            }
        }
        alertView.addAction(closeAction)
        present(alertView, animated: true) {
        }
    }
    
    /*
    func logFirebaseAnalytics(category: String, params: [String: Any]) -> Void {
        FIRAnalytics.logEvent(withName: category, parameters: params as? [String: NSObject])
    }
    */
    
    func screenLogGoogleAnalystics(key: String, value: String) -> Void {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(key, value: value)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder!.build() as [NSObject : AnyObject])
    }
    
    func eventLogGoogleAnalystics(eventData: [NSObject : AnyObject]) -> Void {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "View Entry")
        tracker?.send(eventData)
        tracker?.set(kGAIScreenName, value: nil)
    }

    
    func getTimeDurationString(totalSeconds: TimeInterval) -> String {
        let hour: Int = Int(totalSeconds / 3600)
        let minutes: Int = Int(totalSeconds) % 3600 / 60
        let second: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        var result: String = ""
        if hour > 0 {
            result = String(hour) + "h "
        }
        if minutes > 0 {
            result = result + String(minutes) + "m "
        }
        result = result + String(second) + "s"
        return result
    }
}
