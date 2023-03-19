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
}
