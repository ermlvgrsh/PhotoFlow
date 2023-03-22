import Foundation
import Kingfisher
import UIKit



protocol ImageListViewPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func setNotification()
    func configCell(for cell: ImageListCell,
                    with indexPath: IndexPath,
                    photo: Photo)
    func getDate(for cell: ImageListCell, photo: Photo)
    func setLike(for cell: ImageListCell, isLiked: Bool)
    
    
}
final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    var helper: ImageListCellHelperProtocol?
        
    //MARK: Variables
       var alertProtocol: AlertProtocol?
       //массив хранящий в себе фото
        var photos: [Photo] = []
       //Форматтер для оформления даты
       private lazy var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .long
           formatter.timeStyle = .none
           return formatter
       }()
        let showSingleImageSegueIdentifier = "ShowSingleImage"
        let imageListService = ImageListService.shared
       private var imageListServiceObserver: NSObjectProtocol?
       private let notificationCenter = NotificationCenter.default

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
    
    func viewDidLoad() {
        setNotification()
        
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
    
    func configCell(for cell: ImageListCell,
                    with indexPath: IndexPath,
                    photo: Photo) {
        helper?.configure(cell, with: photo)
        //устанаваливаем дату для фотографии
        getDate(for: cell, photo: photo)
        //устанавливаем лайк на фотографию
        setLike(for: cell, isLiked: photo.isLiked)
        
    }
    func fetchPhotosNextPage() {
        imageListService.fetchPhotosNextPage()
    }
    
    func setNotification() {
        imageListServiceObserver = notificationCenter.addObserver(forName: ImageListService.didChangeNotification,
                                                                     object: imageListService,
                                                                     queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        if photos.isEmpty {
            fetchPhotosNextPage()
        }
    }
    //создаем метод по обновлению фотографий в нашем tableView
     func updateTableViewAnimated() {
        
        let previousCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        guard let tableView = view?.tableView else { return }
        
        if previousCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (previousCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
       guard
        let url = URL(string:photo.thumbImageURL),
        let image = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString, options: nil)
        else { return 160 }
        //добавляю через переменную метод высчитывания соотношения сторон
        let imageCrop = image.getCropRatio()
        return tableView.frame.width / imageCrop
        
        
    }
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //проверяем идентификатор сегвея, поскольку может быть больше одного
        if segue.identifier == showSingleImageSegueIdentifier {
            //делаем преобразования типа для свойства .destination в ожидаемое для нас SingleImageViewContoller
            let viewController = segue.destination as! SingleImageViewContoller
            //делаем преобразования типа для sender, если там будет что то другое - мы не сможем сконфигурировать переход
            let indexPath = sender as! IndexPath
            //получаем индекс картинки и саму картинку из ресурсов
            viewController.largeImageURL = imageListService.getFullImageURL(with: indexPath)
        }
    }
    func presentPhotos(on tableView: UITableView, photos: [Photo]) {
        self.photos = photos
        
        DispatchQueue.main.async {
            tableView.reloadData()
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

