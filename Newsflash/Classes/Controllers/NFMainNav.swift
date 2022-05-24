
import UIKit

class NFMainNav: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var vc: NFViewController!
        if appManager().getUsername() == nil {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "NFUserInfoVC") as! NFUserInfoVC
        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "MainFeedVC") as! NFMainFeedVC
        }
        self.viewControllers = [vc]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
