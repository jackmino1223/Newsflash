
import UIKit
import SVProgressHUD
import SwiftyJSON

class NFChannelVC: NFViewController, UITableViewDataSource, UITableViewDelegate, NFChannelCellDelegate, UITextFieldDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnAllChannels: UIButton!
    @IBOutlet weak var btnFeaturedChannels: UIButton!
    @IBOutlet weak var txtSearchBox: UITextField!
    @IBOutlet weak var scrviewTableContainer: UIScrollView!
    @IBOutlet weak var tblAllChannels: UITableView!
    @IBOutlet weak var tblFeaturedChannels: UITableView!
    @IBOutlet weak var constraintLeftSpaceOfUnderline: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomSpace: NSLayoutConstraint!
    
    var fromUserInfoVC: Bool = false
    
    private var indexOfChannels: [Bool] = []
    private var featuredChannels: [NFFeedModel] = []
    private var searchResultChannels: [NFFeedModel] = []
    private var isSelectedAllChannel: Bool = true
    
    private var isChangedChannel: Bool = false
    
    fileprivate var weatherChannelId: Int = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indexOfChannels = Array<Bool>(repeating: false, count: appManager().allChannel.count)
        
        var index: Int = 0
        for originalChannel in appManager().allChannel {
            for subscribedChannel in appManager().subscribed {
                if originalChannel.identifier == subscribedChannel.identifier {
                    indexOfChannels[index] = true
                    break
                }
            }
            if originalChannel.featured {
                featuredChannels.append(originalChannel)
            }
            index += 1
        }

        if let path = Bundle.main.path(forResource: "WeatherChannel", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                //                if let jsonString = String(data: data, encoding: .utf8) {
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    
                    let weatherChannel = NFFeedModel(data: jsonObj)
                    weatherChannelId = weatherChannel.identifier
                    featuredChannels.append(weatherChannel)
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        self.txtSearchBox.isHidden = true
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        self.txtSearchBox.leftView = leftPadding
        self.txtSearchBox.leftViewMode = .always
        self.txtSearchBox.delegate = self
        self.txtSearchBox.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        if fromUserInfoVC {
            self.btnBack.setImage(nil, for: .normal)
            self.btnBack.setTitle("Done", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.screenLogGoogleAnalystics(key: kGAIScreenName, value: "Channel")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.selectAllChannel(false)
        self.scrviewTableContainer.setContentOffset(CGPoint(x: self.scrviewTableContainer.frame.width, y: 0), animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func keyboardWillShowRect(_ keyboardSize: CGSize) {
        self.constraintBottomSpace.constant = keyboardSize.height
        updateConstraintWithAnimate()
    }
    
    override func keyboardWillHideRect() {
        self.constraintBottomSpace.constant = 0
        updateConstraintWithAnimate()
    }
    
    private func selectAllChannel(_ allChannel: Bool = true) {
        if isSelectedAllChannel != allChannel {
            isSelectedAllChannel = allChannel
            if allChannel {
                self.constraintLeftSpaceOfUnderline.constant = self.btnAllChannels.frame.origin.x
            } else {
                self.constraintLeftSpaceOfUnderline.constant = self.btnFeaturedChannels.frame.origin.x
            }
            updateConstraintWithAnimate()
        }
    }
    
    // MARK: - UIScrollView delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrviewTableContainer {
            self.selectAllChannel(scrollView.contentOffset.x == 0)
        }
    }
    
    // MARK: - UITableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.txtSearchBox.isHidden {
            if tableView == self.tblAllChannels {
                return appManager().allChannel.count
            } else {
                return featuredChannels.count
            }
        } else {
            return searchResultChannels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NFChannelCell.cellIdentifier()) as! NFChannelCell
        if tableView == self.tblAllChannels {
            if self.txtSearchBox.isHidden {
                cell.channel = appManager().allChannel[indexPath.row]
                cell.btnCheckMark.isSelected = indexOfChannels[indexPath.row]
            } else {
                cell.channel = searchResultChannels[indexPath.row]
                cell.btnCheckMark.isSelected = false
                appManager().subscribed.forEach({ (subscribedChannel: NFFeedModel) in
                    if subscribedChannel.identifier == cell.channel.identifier {
                        cell.btnCheckMark.isSelected = true
                        return
                    }
                })
            }
        } else {
            let featuredChannel = featuredChannels[indexPath.row]
            cell.channel = featuredChannel
            if featuredChannel.identifier == weatherChannelId { // Weather channel
                cell.btnCheckMark.isSelected = appManager().getAllowUserLocation()
            } else {
                cell.btnCheckMark.isSelected = false
                for subscribedChannel in appManager().subscribed {
                    if subscribedChannel.identifier == featuredChannel.identifier {
                        cell.btnCheckMark.isSelected = true
                        break
                    }
                }
            }
        }
        
        cell.delegate = self

        return cell
    }
    
    // MARK: ChannelCell delegate
    func selectedChannelWithCell(_ cell: NFChannelCell) {
        
        if cell.channel.identifier != weatherChannelId {
            isChangedChannel = true
        }
        
        let checkSubscribed = { () -> Void in
            let selected = cell.btnCheckMark.isSelected
            if cell.channel.identifier == self.weatherChannelId { // Weather channel
                self.appManager().setAllowUserLocation(selected)
            } else {
                if selected {
                    self.appManager().subscribed.append(cell.channel)
                } else {
                    
                    for index in 0...self.appManager().subscribed.count - 1 {
                        if cell.channel.identifier == self.appManager().subscribed[index].identifier {
                            self.appManager().subscribed.remove(at: index)
                            break
                        }
                    }
                }
                if let index = self.appManager().allChannel.index(of: cell.channel) {
                    self.indexOfChannels[index] = selected
                }
                self.tblAllChannels.reloadData()
            }
        }
        
        if self.txtSearchBox.isHidden {
            if isSelectedAllChannel {
                if let indexPath = self.tblAllChannels.indexPath(for: cell) {
                    let selected = cell.btnCheckMark.isSelected
                    indexOfChannels[indexPath.row] = selected
                    if selected {
                        appManager().subscribed.append(cell.channel)
                    } else {
                        
                        for index in 0...appManager().subscribed.count - 1 {
                            if cell.channel.identifier == appManager().subscribed[index].identifier {
                                appManager().subscribed.remove(at: index)
                                break
                            }
                        }
                    }
                    self.tblFeaturedChannels.reloadData()
                }

            } else {
                checkSubscribed()
            }
        } else {
            checkSubscribed()
        }
    }
    
    // MARK: - UITextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchChannelWithName(nil)
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        searchChannelWithName(textField.text)
    }
    
    // MARK: Search Channel
    private func searchChannelWithName(_ name: String?) {
        if name == nil {
            searchResultChannels = appManager().allChannel
            
        } else {
            searchResultChannels.removeAll()
            appManager().allChannel.forEach({ (channel: NFFeedModel) in
                if channel.name.lowercased().contains(name!.lowercased()) {
                    searchResultChannels.append(channel)
                }
            })
            
        }
        self.tblAllChannels.reloadData()
    }
    
    // MARK: Update channel
    private func updateChannel(complete: @escaping (() -> Void)) {
        SVProgressHUD.show(withStatus: "Updating Channel...")
        
        let uuid = appManager().uuid
        
        var subscribedIds: [Int] = []
        appManager().subscribed.forEach { (channel: NFFeedModel) in
            subscribedIds.append(channel.identifier)
        }
        
        requestManager().updateMyChannel(uuid, deviceToken: appManager().deviceToken, channelIds: subscribedIds) { (error: Error?) in
            if error == nil {
                complete()
            } else {
                self.showSimpleAlert("Error", message: error?.localizedDescription, closeButton: "Close", completion: {
                    
                })
            }
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onPressBack(sender: AnyObject) {
        if fromUserInfoVC {
            updateChannel {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainFeedVC")
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else {
            if isChangedChannel {
                updateChannel {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification_UpdateChannel), object: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onPressChannelType(sender: AnyObject) {
        let selecting = (sender as? UIButton == self.btnAllChannels)
        if selecting {
            self.scrviewTableContainer.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            self.scrviewTableContainer.setContentOffset(CGPoint(x: self.scrviewTableContainer.frame.width, y: 0), animated: true)
        }
        self.selectAllChannel(selecting)
    }
    
    @IBAction func onPressSearch(sender: AnyObject) {
            if self.txtSearchBox.isHidden {
                self.txtSearchBox.text = nil
                self.txtSearchBox.isHidden = false
                self.txtSearchBox.becomeFirstResponder()
                
                self.selectAllChannel()
                self.scrviewTableContainer.isScrollEnabled = false
                self.scrviewTableContainer.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                
                searchResultChannels = appManager().allChannel
                self.tblAllChannels.reloadData()
            } else {
                self.txtSearchBox.isHidden = true
                self.txtSearchBox.resignFirstResponder()
                
                self.scrviewTableContainer.isScrollEnabled = true
                self.tblAllChannels.reloadData()
            }
    }
    
    @IBAction func onPressDone(sender: AnyObject) {
        appManager().subscribed.removeAll()
        var subscribedIds: [Int] = []
        for index in 0...indexOfChannels.count - 1 {
            if indexOfChannels[index] == true {
                let selectedChannel = appManager().allChannel[index]
                appManager().subscribed.append(selectedChannel)
                subscribedIds.append(selectedChannel.identifier)
            }
        }
        
        self.btnBack.isEnabled = false
        
        let uuid = appManager().uuid
        requestManager().updateMyChannel(uuid, deviceToken: appManager().deviceToken, channelIds: subscribedIds) { (error: Error?) in
            if error == nil {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                self.showSimpleAlert(error?.localizedDescription, message: "Error", closeButton: "Close", completion: { 
                    self.btnBack.isEnabled = true
                })
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
