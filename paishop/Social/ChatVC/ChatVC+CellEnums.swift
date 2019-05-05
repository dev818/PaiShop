

import UIKit


extension MessageContentType {
    
    func chatCellHeight(_ model: ChatMessageModel) -> CGFloat {
        switch self {
        case .Text:
            return ChatTextCell.layoutHeight(model)
        case .Time:
            return ChatTimeCell.heightForCell()
        case .Image:
            return ChatImageCell.layoutHeight(model)
        }
    }
    
    func chatCell(_ tableView: UITableView, index: IndexPath, model: ChatMessageModel, vc: ChatVC) -> UITableViewCell? {
        switch self {
        case .Text:
            let cell: ChatTextCell = tableView.ts_dequeueReusableCell(ChatTextCell.self)
            cell.delegate = vc
            cell.setCellContent(model)
            return cell
        case .Time:
            let cell: ChatTimeCell = tableView.ts_dequeueReusableCell(ChatTimeCell.self)
            cell.setCellContent(model)
            return cell
        case .Image:
            let cell: ChatImageCell = tableView.ts_dequeueReusableCell(ChatImageCell.self)
            cell.delegate = vc
            cell.setCellContent(model)
            return cell
        }
    }
    
}

















