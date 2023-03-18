import UIKit
import ProgressHUD
import Kingfisher

final class ImageListViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK: Variables
       var alertProtocol: AlertProtocol?
       //массив хранящий в себе фото
       private var photos: [Photo] = []
       //Форматтер для оформления даты
       private lazy var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .long
           formatter.timeStyle = .none
           return formatter
       }()
       private let showSingleImageSegueIdentifier = "ShowSingleImage"
       private let imageListService = ImageListService.shared
       private var imageListServiceObserver: NSObjectProtocol?
       private let notificationCenter = NotificationCenter.default
       override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }

       
       //MARK: Functions
       
       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.delegate = self
           tableView.dataSource = self
           tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
           imageListServiceObserver = notificationCenter.addObserver(forName: ImageListService.didChangeNotification,
                                                                        object: imageListService,
                                                                        queue: .main) { [weak self] _ in

               self?.updateTableViewAnimated()
           }
           if photos.isEmpty {
               imageListService.fetchPhotosNextPage()
           }
       }
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           setNeedsStatusBarAppearanceUpdate()
       }
       
       private func configCell(for cell: ImageListCell,
                       with indexPath: IndexPath,
                       photo: Photo) {
           //устанаваливаем дату для фотографии
           getDate(for: cell, photo: photo)
           //устанавливаем лайк на фотографию
           setLiked(for: cell, isLiked: photo.isLiked)
           
       }
       // метод открытия нужной картинки в потоке через сегвей
       override func prepare(for segue: UIStoryboardSegue,
                             sender: Any?) {
           //проверяем идентификатор сегвея, поскольку может быть больше одного
           if segue.identifier == showSingleImageSegueIdentifier {
               //делаем преобразования типа для свойства .destination в ожидаемое для нас SingleImageViewContoller
               let viewController = segue.destination as! SingleImageViewContoller
               //делаем преобразования типа для sender, если там будет что то другое - мы не сможем сконфигурировать переход
               let indexPath = sender as! IndexPath
               //получаем индекс картинки и саму картинку из ресурсов
               viewController.largeImageURL = imageListService.getFullImageURL(with: indexPath)
           } else {
               // если неизвестный сегвей - передаем управление ему
               super.prepare(for: segue, sender: sender)
           }
       }
       
       //создаем метод по обновлению фотографий в нашем tableView
       private func updateTableViewAnimated() {
           
           let previousCount = photos.count
           let newCount = imageListService.photos.count
           photos = imageListService.photos
           
           if previousCount != newCount {
               tableView.performBatchUpdates {
                   let indexPaths = (previousCount..<newCount).map { IndexPath(row: $0, section: 0) }
                   tableView.insertRows(at: indexPaths, with: .automatic)
               } completion: { _ in }
           }
       }
       
       
   }
   //MARK: Extensions
   // создал расширение нашего класса для использования протокола UITableViewDelegate
   extension ImageListViewController: UITableViewDelegate {
       //метод отвечает за действия, которые будут выполнены при тапе по ячейке таблицы
       //адрес ячейки который хранится в indexPath передается в качестве аргумента
       func tableView(_ tableView: UITableView,
                      didSelectRowAt indexPath: IndexPath) {
           //выполняем переход сегвей из общего потока в конкретное фото
           // 1 аргумент - идентификатор, который мы задали в storyboard; 2 используется в override func prepare
           performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
       }
       //метод который отвечает за высоту ячейки
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
   }
   //создал расширение для UIImage которое высчитывает соотношения сторон картинок
   extension UIImage {
       //метод который высчитывает соотношение сторон картинки
       func getCropRatio() -> CGFloat {
           let widthRatio = CGFloat(self.size.width/self.size.height)
           return widthRatio
       }
   }
   //создал расширение нашего класса для использования протокола UiTableViewDataSource
   extension ImageListViewController: UITableViewDataSource {
       //метод определеяющий количество ячеек в конкретной секции
       func tableView(_ tableView: UITableView,
                      numberOfRowsInSection section: Int) -> Int {
           return photos.count
       }
       //метод создания ячейки, наполнением ее данными и передачи в таблицу
       func tableView(_ tableView: UITableView,
                      cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let photo = photos[indexPath.row]
           let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
           guard let imageListCell = cell as? ImageListCell, let url = URL(string: photo.thumbImageURL) else {
               return UITableViewCell()
           }
           imageListCell.delegate = self
           imageListCell.cellImage.kf.indicatorType = .activity
           imageListCell.imageURL = url
           imageListCell.cellImage.kf.setImage(with: url,
                                               placeholder: UIImage(named: "Stub")) { result in
               switch result {
               case .success:
                   if imageListCell.imageURL == url {
                       tableView.reloadRows(at: [indexPath], with: .automatic)
                   }
                   
               case .failure(let error):
                   print(error.localizedDescription)
               }
           }
           
           configCell(for: imageListCell, with: indexPath, photo: photo)
           return imageListCell
       }
       func tableView(_ tableView: UITableView,
                      willDisplay cell: UITableViewCell,
                      forRowAt indexPath: IndexPath) {
           if let cell = cell as? ImageListCell, cell.cellImage == nil {
               ProgressHUD.show()
           }
           let lastCell = indexPath.row + 1 == photos.count
           if lastCell {
               imageListService.fetchPhotosNextPage()
           }
           
       }
       private func getDate(for cell: ImageListCell, photo: Photo) {
           if let date = photo.createdAt {
               cell.cellDate.text = dateFormatter.string(from: date)
           } else {
               cell.cellDate.text = nil
           }
       }
       private func setLiked(for cell: ImageListCell, isLiked: Bool) {
           let active = UIImage(named: "like")
           let noActive = UIImage(named: "dont_like")
           let likedOrNot = isLiked ? active : noActive
           cell.cellButton.setImage(likedOrNot, for: .normal)
       }
   }
   extension ImageListViewController: ImageListCellDelegate {
       func didTapLikeButton(_ cell: ImageListCell) {
           guard let indexPath = tableView.indexPath(for: cell) else { return }
           let photo = photos[indexPath.row]
           UIBlockingProgressHUD.show()
           imageListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
               guard let self = self else { return }
               switch result {
               case .success():
                   self.photos = self.imageListService.photos
                   self.setLiked(for: cell, isLiked: self.photos[indexPath.row].isLiked)
                   self.tableView.reloadData()
                   UIBlockingProgressHUD.dismiss()
               case .failure(let error):
                   print(error)
                   self.alertProtocol?.requestAlert(title: "Ошибка сети", message: "Не удалось поставить лайк", buttonText: "OK")
               }
           }
       }
   }
