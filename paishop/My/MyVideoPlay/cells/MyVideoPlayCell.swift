
import UIKit

class MyVideoPlayCell: UITableViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!    
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.setImage(ImageAsset.my_store_trash.image.withRenderingMode(.alwaysTemplate), for: .normal)
            deleteButton.tintColor = .white
        }
    }
    @IBOutlet weak var durationBgView: RoundRectView!
    @IBOutlet weak var durationLabel: UILabel!
    
    var video: LiveVideoModel!
    var index: Int!
    var parentVC: MyVideoPlayVC!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func setCellContent(_ video: LiveVideoModel, index: Int, vc: MyVideoPlayVC) {
        self.video = video
        self.index = index
        self.parentVC = vc
        
        let resizedUrl = Utils.getResizedImageUrlString(video.image!, width: "800")
        videoImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        let views = video.views!
        let viewsCount = "\(views)人"
        viewsLabel.text = viewsCount
        titleLabel.text = video.title
        durationLabel.text = getDurationString(video.duration!)
        if video.active! {
            stateButton.setImage(ImageAsset.my_store_download.image.withRenderingMode(.alwaysTemplate), for: .normal)
            stateButton.tintColor = .white
            statusLabel.text = "上架"
        } else {
            stateButton.setImage(ImageAsset.my_store_upload.image.withRenderingMode(.alwaysTemplate), for: .normal)
            stateButton.tintColor = .white
            statusLabel.text = "未上架"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func changeState(_ sender: UIButton) {
        if video.active! {
            parentVC.presentAlert("你真的想未上架吗?", completion: {
                self.inactiveVideo()
            })
        } else {
            parentVC.presentAlert("你真的想上架吗?", completion: {
                self.activeVideo()
            })
        }
    }
    
    @IBAction func selectDelete(_ sender: UIButton) {
        parentVC.presentAlert("你真的想删除吗?") {
            self.deleteVideo()
        }
    }
    
    private func getDurationString(_ duration: Int) -> String {
        var hour = 0, minute = 0, second = 0
        var hourStr = "00", minuteStr = "00", secondStr = "00"
        hour = duration / 3600
        minute = (duration % 3600) / 60
        second = (duration % 3600 ) % 60
        if hour < 10 {
            hourStr = "0\(hour)"
        } else {
            hourStr = "\(hour)"
        }
        
        if minute < 10 {
            minuteStr = "0\(minute)"
        } else {
            minuteStr = "\(minute)"
        }
        
        if second < 10 {
            secondStr = "0\(second)"
        } else {
            secondStr = "\(second)"
        }
        
        if hour > 0 {
            return hourStr + ":" + minuteStr + ":" + secondStr
        } else {
            return minuteStr + ":" + secondStr
        }
        
    }
    
    
    private func deleteVideo() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查网络连接!")
            return
        }
        let parameters: [String : Any] = [
            "video" : video.id!
        ]
        MyAPI.shared.liveDelete(params: parameters) { (json, success) in
            if success {
                print("Video Delete...")
                print(json)
                DispatchQueue.main.async {
                    ProgressHUD.showSuccessWithStatus("成功删除!")
                    self.parentVC.videos.remove(at: self.index)
                    self.parentVC.tableView.reloadData()
                    if self.parentVC.videos.count > 0 {
                        self.parentVC.noDataView.isHidden = true
                    } else {
                        self.parentVC.noDataView.isHidden = false
                    }
                }
            } else {
                MyAPI.shared.liveDelete(params: parameters, completion: { (json1, success1) in
                    if success1 {
                        DispatchQueue.main.async {
                            ProgressHUD.showSuccessWithStatus("成功删除!")
                            self.parentVC.videos.remove(at: self.index)
                            self.parentVC.tableView.reloadData()
                            if self.parentVC.videos.count > 0 {
                                self.parentVC.noDataView.isHidden = true
                            } else {
                                self.parentVC.noDataView.isHidden = false
                            }
                        }
                    } else {
                        ProgressHUD.showErrorWithStatus("出了点问题，请重试.")
                    }
                })
            }
        }
        
    }
    
    private func activeVideo() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查网络连接!")
            return
        }
        let parameters: [String : Any] = [
            "video" : video.id!
        ]
        MyAPI.shared.liveActive(params: parameters) { (json, success) in
            if success {
                //print("Item Active...")
                //print(json)
                ProgressHUD.showSuccessWithStatus("成功上架!")
                self.parentVC.videos[self.index].active = true
                self.video.active = true
                self.stateButton.setImage(ImageAsset.my_store_download.image.withRenderingMode(.alwaysTemplate), for: .normal)
                self.statusLabel.text = "上架"
            } else {
                // try again...
                MyAPI.shared.liveActive(params: parameters, completion: { (json1, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功上架!")
                        self.parentVC.videos[self.index].active = true
                        self.video.active = true
                        self.stateButton.setImage(ImageAsset.my_store_download.image.withRenderingMode(.alwaysTemplate), for: .normal)
                        self.statusLabel.text = "上架"
                    } else {
                        ProgressHUD.showErrorWithStatus("出了点问题，请重试.")
                    }
                })
            }
        }
    }
    
    private func inactiveVideo() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查网络连接!")
            return
        }
        let parameters: [String : Any] = [
            "video" : video.id!
        ]
        MyAPI.shared.liveInactive(params: parameters) { (json, success) in
            if success {
                //print("Item Inactive...")
                //print(json)
                ProgressHUD.showSuccessWithStatus("成功未上架!")
                self.parentVC.videos[self.index].active = false
                self.video.active = false
                self.stateButton.setImage(ImageAsset.my_store_upload.image.withRenderingMode(.alwaysTemplate), for: .normal)
                self.statusLabel.text = "未上架"
            } else {
                // try again...
                MyAPI.shared.liveInactive(params: parameters, completion: { (json1, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功未上架!")
                        self.parentVC.videos[self.index].active = false
                        self.video.active = false
                        self.stateButton.setImage(ImageAsset.my_store_upload.image.withRenderingMode(.alwaysTemplate), for: .normal)
                        self.statusLabel.text = "未上架"
                    } else {
                        ProgressHUD.showErrorWithStatus("出了点问题，请重试.")
                    }
                })
            }
        }
    }
    
    
}










