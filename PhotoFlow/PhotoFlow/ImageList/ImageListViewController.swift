import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    func updateTableViewAnimated()
}

final class ImageListViewController: UIViewController, ImageListViewControllerProtocol {
    
    private let showSingleImageSegueIndetifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    private let alertProtocol: AlertProtocol? = nil
    var photos: [Photo] = [] {
        didSet {
            if photos.isEmpty {
                print("empty array")
            } else {
                print("array has \(photos.count) photos")
            }
        }
    }
    var presenter: ImageListViewPresenterProtocol?

    
    func configure(_ presenter: ImageListViewPresenterProtocol) {
        var presenter = presenter
        self.presenter = presenter
        presenter.view = self
    }
    //MARK: IBOutlets
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
        guard let presenter = presenter else { return }
        self.configure(presenter)
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
        let previousCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if previousCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (previousCount..<newCount).map { row in
                    IndexPath(row: row, section: 0)
                    
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImageListViewController: ImageListCellDelegate {
    func didTapLikeButton(_ cell: ImageListCell) {
               guard var indexPath = tableView.indexPath(for: cell) else { return }
               let photo = photos[indexPath.row]
               UIBlockingProgressHUD.show()
               imageListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
                   guard let self = self else { return }
                   switch result {
                   case .success():
                       self.photos = self.imageListService.photos
                       cell.setLike(for: cell, isLiked: self.photos[indexPath.row].isLiked)
                       UIBlockingProgressHUD.dismiss()
                   case .failure(let error):
                       print(error)
                       self.alertProtocol?.requestAlert(title: "Ошибка сети", message: "Не удалось поставить лайк", buttonText: "OK")
                   }
               }
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
        cell.getDate(for: cell, photo: photo)
        cell.delegate = self
        let url = URL(string: photo.thumbImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "Stub"), options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)]) { _ in
            
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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
