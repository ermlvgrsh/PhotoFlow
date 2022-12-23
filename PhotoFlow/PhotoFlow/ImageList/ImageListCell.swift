import Foundation
import UIKit

final class ImageListCell: UITableViewCell {
    static let reuseIdentifier = "ImageListCell"
    
    //MARK: Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellButton: UIButton!
}
