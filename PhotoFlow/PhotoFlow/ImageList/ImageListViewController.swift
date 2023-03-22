import UIKit
import ProgressHUD
import Kingfisher
import ProgressHUD

protocol ImageListViewControllerProtocol {
    var presenter: ImageListViewPresenter { get set }
    var tableView: UITableView? { get set }
    
}

final class ImageListViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var tableView: UITableView!
    
    //MARK: Variables
    var helper: ImageListCellHelper?
    var presenter: ImageListViewPresenter?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
       //MARK: Functions
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setTableView()
           presenter?.viewDidLoad()
       }
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           setNeedsStatusBarAppearanceUpdate()
       }
       
       private func configCell(for cell: ImageListCell,
                       with indexPath: IndexPath,
                       photo: Photo) {
           presenter?.configCell(for: cell, with: indexPath, photo: photo)
           
       }
       // метод открытия нужной картинки в потоке через сегвей
       override func prepare(for segue: UIStoryboardSegue,
                             sender: Any?) {
           if segue.identifier == presenter?.showSingleImageSegueIdentifier  {
               presenter?.prepare(for: segue, sender: sender)
           } else {
               // если неизвестный сегвей - передаем управление ему
               super.prepare(for: segue, sender: sender)
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
           guard let segueIdentifier = presenter?.showSingleImageSegueIdentifier else { return }
           performSegue(withIdentifier: segueIdentifier, sender: indexPath)
       }
       //метод который отвечает за высоту ячейки
       func tableView(_ tableView: UITableView,
                      heightForRowAt indexPath: IndexPath) -> CGFloat {
           let imageCrop = presenter?.tableView(tableView, heightForRowAt: indexPath)
           return imageCrop ?? 160
       }
   }
  
   //создал расширение нашего класса для использования протокола UiTableViewDataSource
   extension ImageListViewController: UITableViewDataSource {
       //метод определеяющий количество ячеек в конкретной секции
       func tableView(_ tableView: UITableView,
                      numberOfRowsInSection section: Int) -> Int {
           let photos = bindSome(for: presenter?.photos.count)
           return photos
       }
       //метод создания ячейки, наполнением ее данными и передачи в таблицу
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let photo = presenter?.photos[indexPath.row] else { return UITableViewCell() }
           let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
           guard let imageListCell = cell as? ImageListCell else  {
               return UITableViewCell()
           }
           configCell(for: imageListCell, with: indexPath, photo: photo)
           return imageListCell
       }
       
       func tableView(_ tableView: UITableView,
                      willDisplay cell: UITableViewCell,
                      forRowAt indexPath: IndexPath) {
           helper?.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
       }
}

   extension ImageListViewController: ImageListCellDelegate {
       func didTapLikeButton(_ cell: ImageListCell) {
           helper?.didTapLikeButton(cell)
       }
   }
