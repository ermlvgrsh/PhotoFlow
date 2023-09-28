import Foundation
import UIKit

protocol ImageListCellDelegate {
    func didTapLikeButton(_ cell: ImageListCell)
}
//MARK: Класс отвечающий за ячейки фотографий
final class ImageListCell: UITableViewCell {
    static let reuseIdentifier = "ImageListCell"
    var imageURL: URL?
    var delegate: ImageListCellDelegate?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellButton: UIButton!
    
    

    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        cellImage.kf.cancelDownloadTask()
    }
    @IBAction private func didTapLikeButton() {
        delegate?.didTapLikeButton(self)
    }
    func getDate(for cell: ImageListCell, photo: Photo) {
        if let date = photo.createdAt {
            cell.cellDate.text = dateFormatter.string(from: date)
        } else {
            cell.cellDate.text = nil
        }
    }
    func setLike(for cell: ImageListCell, isLiked: Bool) {
       let active = UIImage(named: "like")
       let noActive = UIImage(named: "dont_like")
       let likedOrNot = isLiked ? active : noActive
       cell.cellButton.setImage(likedOrNot, for: .normal)
   }
}

