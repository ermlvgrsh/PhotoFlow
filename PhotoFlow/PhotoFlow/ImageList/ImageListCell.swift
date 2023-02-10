import Foundation
import UIKit

//MARK: Класс отвечающий за ячейки фотографий
final class ImageListCell: UITableViewCell {
    static let reuseIdentifier = "ImageListCell"
    
    //MARK: Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellButton: UIButton!
}
