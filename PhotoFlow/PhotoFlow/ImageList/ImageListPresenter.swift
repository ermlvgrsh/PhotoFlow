import Foundation
import Kingfisher
import UIKit

protocol ImageListViewPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get set }
    func viewDidLoad()
    func changeLikeStatus(for photo: Photo, isLiked: Bool)
    func setNotification()
    func fetchPhotosNextPage()
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    
    var view: ImageListViewControllerProtocol?
    
    //MARK: Variables
    var alertProtocol: AlertProtocol?
    //массив хранящий в себе фото
    var photos: [Photo] = []
    //Форматтер для оформления даты
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imageListService = ImageListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    private let notificationCenter = NotificationCenter.default
    
    func viewDidLoad() {
        setNotification()
    }

    func changeLikeStatus(for photo: Photo, isLiked: Bool) {
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoID: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print(error)
                self.alertProtocol?.requestAlert(title: "Ошибка сети", message: "Не удалось поставить лайк", buttonText: "OK")
            }
        }
    }
    
    func fetchPhotosNextPage() {
        imageListService.fetchPhotosNextPage()
    }
    
    func setNotification() {
        imageListServiceObserver = notificationCenter.addObserver(forName: ImageListService.didChangeNotification,
                                                                  object: imageListService,
                                                                  queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.view?.updateTableViewAnimated()
        }
        if photos.isEmpty {
            fetchPhotosNextPage()
            view?.updateTableViewAnimated()
        }
    }
}


//создал расширение для UIImage которое высчитывает соотношения сторон картинок
extension UIImage {
    //метод который высчитывает соотношение сторон картинки
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width/self.size.height)
        return widthRatio
    }
}

