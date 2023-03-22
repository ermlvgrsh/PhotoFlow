import Foundation
import UIKit
import Kingfisher

protocol ImageListCellHelperProtocol {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath)
    func configure(_ cell: ImageListCell, with photo: Photo)
    
    
}

final class ImageListCellHelper: ImageListCellHelperProtocol, ImageListCellDelegate {
    
    var view: ImageListViewControllerProtocol?
    var presenter: ImageListViewPresenter?
    
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if let cell = cell as? ImageListCell, cell.cellImage == nil {
            UIBlockingProgressHUD.show()
        }
        let lastCell = indexPath.row + 1 == presenter?.photos.count
        if lastCell {
            presenter?.imageListService.fetchPhotosNextPage()
        }
    }
    
    func configure(_ cell: ImageListCell, with photo: Photo) {
        guard let url = URL(string: photo.thumbImageURL) else { return }
        cell.delegate = self
        cell.cellImage.kf.indicatorType = .activity
        cell.imageURL = url
        cell.cellImage.kf.setImage(with: url,
                                   placeholder: UIImage(named: "Stub")) { result in
            switch result {
            case .success:
                if cell.imageURL == url {
                    guard let tableView = self.view?.tableView else { return }
                    guard let photos = self.presenter?.photos else { return }
                    self.presenter?.presentPhotos(on: tableView, photos: photos)
                }
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    func didTapLikeButton(_ cell: ImageListCell) {
        guard let indexPath = view?.tableView?.indexPath(for: cell) else { return }
        guard let photo = presenter?.photos[indexPath.row] else { return }
        presenter?.changeLikeStatus(for: photo, isLiked: !photo.isLiked)
    }
}
