
import UIKit
import SwiftLocation
import CoreLocation

let animateDuration: TimeInterval = 1

class NFUserInfoVC: NFViewController, UITextFieldDelegate {

    @IBOutlet weak var viewFirstStep: UIView!
    @IBOutlet weak var viewSecondStep: UIView!
    @IBOutlet weak var viewLastStep: UIView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var lblSecondTitle: UILabel!
    @IBOutlet weak var lblLastTitle: UILabel!
    @IBOutlet weak var viewCursor: UIView!
    
    @IBOutlet weak var btnNotNow: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var constraintVSpaceOfNotNow: NSLayoutConstraint!
    @IBOutlet weak var constraintVSpaceOfContinue: NSLayoutConstraint!
    
    fileprivate var stepNumber: Int = 0
    fileprivate var username: String = ""
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        viewSecondStep.alpha = 0
        viewSecondStep.isHidden = true
        viewLastStep.alpha = 0
        viewLastStep.isHidden = true
        btnNotNow.alpha = 0
        btnNotNow.isHidden = true
        btnContinue.isEnabled = false
        self.btnContinue.alpha = 0.5
        constraintVSpaceOfContinue.constant = 20
        
        self.txtUsername.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.viewCursor.layer.cornerRadius = 1
        
        blinkCursor(self)
        Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(blinkCursor(_:)), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextField delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.viewCursor.isHidden = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) -> Void {
        if textField.text!.characters.count > 0 {
            self.btnContinue.isEnabled = true
            self.btnContinue.alpha = 1
        } else {
            self.btnContinue.isEnabled = false
            self.btnContinue.alpha = 0.5
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 12 // Bool
    }
    
    func blinkCursor(_ sender: Any) -> Void {
        self.viewCursor.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
            self.viewCursor.alpha = 0
        }, completion: { complete in
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
                self.viewCursor.alpha = 1
            }, completion: { complete in
                
            })
        })
    }
    
    // MARK: - Button
    
    @IBAction func onPressNotNow(_ sender: Any) {
        appManager().setAllowUserLocation(false)
        showLastPage()
    }
    
    @IBAction func onPressContinue(_ sender: Any) {
        if stepNumber == 0 {
            showSecondPage()
        } else if stepNumber == 1 {
            showLastPage()
            appManager().setAllowUserLocation(true)
            let locationManager: LocationManager = Location
            locationManager.allowsBackgroundEvents = false
            let request = locationManager.getLocation(withAccuracy: .city, onSuccess: { (location: CLLocation) in
                let coordinate = location.coordinate
                print("Currnet location : \(coordinate.latitude),\(coordinate.longitude)")
            }, onError: { (location: CLLocation?, error: LocationError) in
                if location != nil {
                    let coordinate = location!.coordinate
                    print("Currnet location : \(coordinate.latitude),\(coordinate.longitude)")
                }
                print(error.localizedDescription)
            })
            request.start()
        } else if stepNumber == 2 {
            gotoChannelVC()
        }
    }
    
    // MARK: - Navigate views
    
    fileprivate func showSecondPage() {
        
        username = self.txtUsername.text!
        appManager().setUsername(username)
        
        self.lblSecondTitle.text = "Hey, \(username)!"

        self.view.endEditing(true)
        viewSecondStep.isHidden = false
        btnNotNow.isHidden = false
        
        self.view.setNeedsUpdateConstraints()
        self.constraintVSpaceOfContinue.constant = 60

        UIView.animate(withDuration: animateDuration, animations: {
            self.viewFirstStep.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { complete in
            self.viewFirstStep.isHidden = true
            
            UIView.animate(withDuration: animateDuration, animations: {
                self.viewSecondStep.alpha = 1
                self.btnNotNow.alpha = 1
            }, completion: { complete in
                
            })
        })
        stepNumber = 1
    }
    
    fileprivate func showLastPage() {
        
        self.lblLastTitle.text = "Last thing,\n\(username)!"

        viewLastStep.isHidden = false
        
        
        UIView.animate(withDuration: animateDuration, animations: {
            self.viewSecondStep.alpha = 0
            self.btnNotNow.alpha = 0
        }, completion: { complete in
            
            self.viewSecondStep.isHidden = true
            self.btnNotNow.isHidden = true

            UIView.animate(withDuration: animateDuration, animations: {
                self.viewLastStep.alpha = 1
            }, completion: { complete in
                
            })
            
        })
        stepNumber = 2
    }
    
    fileprivate func gotoChannelVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChannelVC") as! NFChannelVC
        vc.fromUserInfoVC = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
