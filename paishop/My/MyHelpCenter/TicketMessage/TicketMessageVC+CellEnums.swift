

import Foundation

extension TicketMessageContentType {
    
    func ticketCellHeight(_ model: TicketMessageModel) -> CGFloat {
        switch self {
        case .Text:
            return TicketTextCell.layoutHeight(model)
        case .Time:
            return TicketTimeCell.heightForCell()
        }
    }
    
    func ticketCell(_ tableView: UITableView, index: IndexPath, model: TicketMessageModel, vc: TicketMessageVC) -> UITableViewCell? {
        switch self {
        case .Text:
            let cell: TicketTextCell = tableView.ts_dequeueReusableCell(TicketTextCell.self)
            cell.setCellContent(model)
            return cell
        case .Time:
            let cell: TicketTimeCell = tableView.ts_dequeueReusableCell(TicketTimeCell.self)
            cell.setCellContent(model)
            return cell
        }
    }
    
}
