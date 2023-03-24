import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    func updateTableViewAnimated()
}

final class ImageListViewController: UIViewController, ImageListViewControllerProtocol {
    
    private let showSingleImageSegueIndetifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    internal var photos: [Photo] = []
    var presenter: ImageListViewPresenterProtocol?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func configure(_ presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    @IBOutlet private var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        presenter?.viewDidLoad()
        
    }
    func setTableView() {                                                       //обновляем тэйблВью
        tableView.delegate = self                                               //устанавливаем делегат тэйблВью
        tableView.dataSource = self                                             //устанавливаем датаСоурс тэйблВью
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)   //устанавливаем размер ячейки
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //проверяем идентификатор сегвея, поскольку может быть больше одного
        if segue.identifier == showSingleImageSegueIndetifier {
            //делаем преобразования типа для свойства .destination в ожидаемое для нас SingleImageViewContoller
            let viewController = segue.destination as! SingleImageViewContoller
            //делаем преобразования типа для sender, если там будет что то другое - мы не сможем сконфигурировать переход
            let indexPath = sender as! IndexPath
            //получаем индекс картинки и саму картинку из ресурсов
            viewController.largeImageURL = imageListService.getFullImageURL(with: indexPath)
        }
    }
    
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImageListViewController: ImageListCellDelegate {
    func didTapLikeButton(_ cell: ImageListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
             let photo = photos[indexPath.row]
             presenter?.changeLikeStatus(for: photo, isLiked: !photo.isLiked)
    }
    
}

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ImageListCell, cell.cellImage == nil {
            UIBlockingProgressHUD.show()
        }
        let lastCell = indexPath.row + 1 == photos.count
        if lastCell {
            presenter?.fetchPhotosNextPage()
        }
        
    }
}


extension ImageListViewController {
    func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        getDate(for: cell, photo: photo)
        setLike(for: cell, isLiked: photo.isLiked)
        cell.delegate = self
        let url = URL(string: photo.thumbImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "Stub"), options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)]) { _ in
            
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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

extension ImageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIndetifier, sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
       guard
        let url = URL(string:photo.thumbImageURL),
        let image = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString, options: nil)
        else { return 160 }
        //добавляю через переменную метод высчитывания соотношения сторон
        let imageCrop = image.getCropRatio()
        return tableView.frame.width / imageCrop
    }
}
