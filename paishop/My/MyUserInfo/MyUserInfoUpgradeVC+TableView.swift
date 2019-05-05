

import Foundation

extension MyUserInfoUpgradeVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.degrees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyUserInfoUpgradeCell = tableView.ts_dequeueReusableCell(MyUserInfoUpgradeCell.self)
        cell.setCellContent(self.degrees[indexPath.row], parentVC: self)
        return cell
    }
    
}
