
import UIKit

class NFSplashVC: NFViewController {

    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var lblWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoMainVC(sender: AnyObject) -> Void {
        self.performSegue(withIdentifier: "gotoMainVC", sender: self)
    }
    
    @IBAction func onPressRefresh(sender: AnyObject) {
        getUserInfo()
    }
    
    func getUserInfo() -> Void {
        
        
#if (arch(i386) || arch(x86_64)) && os(iOS)
        let uuid = "Simulator"
#else
        let uuid = UIDevice.current.identifierForVendor!.uuidString
#endif
        
        print("UUID : " + uuid)
        appManager().uuid = uuid
        
        self.indicatorLoading.startAnimating()
        self.btnRefresh.isHidden = true
        self.lblWarning.text = nil
        requestManager().getCustomerChannels(uuid: uuid) { (result: [NFFeedModel]?, error: Error?) in
            if result != nil {
                self.appManager().subscribed = result!
                self.appManager().isLoadedSubscribed = true
                
                self.requestManager().updateDeviceToken()
                
                self.getAllChannel(complete: { (allChannelError: Error?) in
                    if allChannelError != nil {
                        self.indicatorLoading.stopAnimating()
                        self.btnRefresh.isHidden = false
                        self.lblWarning.text = "Server connection is failed.\n" + allChannelError!.localizedDescription
                    } else {
                        
                        /// Success
                        self.indicatorLoading.stopAnimating()
                        self.lblWarning.text = "Successful"
                        self.gotoMainVC(sender: self)
                        
                    }
                })
            } else {
                self.indicatorLoading.stopAnimating()
                self.btnRefresh.isHidden = false
                self.lblWarning.text = "Server connection is failed.\n" + error!.localizedDescription
            }
        }
    }
    
    func getAllChannel(complete: ((Error?) -> Void)?) -> Void {
        requestManager().getChannels(skip: nil, limit: nil) { (result: [NFFeedModel]?, error: Error?) in
            if complete != nil {
                if result != nil {
                    self.appManager().allChannel = result!
                    complete!(nil)
                } else {
                    complete!(error)
                }
                
            }
        }
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
