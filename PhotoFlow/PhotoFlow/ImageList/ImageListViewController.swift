import UIKit

final class ImageListViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK: Variables
    //массив хранящий в себе фото
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    //Форматтер для оформления даты
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    //MARK: Functions
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        //проверяем возможно ли создать картинку с названием из массива, если нет - выходим из функции
        guard let imageView = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        //присваиваем для каждой ячейки картинку
        cell.cellImage.image = imageView
        //присваиваем для каждой даты сегодняшнюю
        cell.cellDate.text = dateFormatter.string(from: Date())
        //Для каждой ячейки с чётным индексом устанавливаем включённый лайк. Для ячеек с нечётным индексом лайк выключен.
        let active = UIImage(named: "like")
        let noActive = UIImage(named: "dont_like")
        let activeOrNot = indexPath.row % 2 == 0 ? noActive : active
        cell.cellButton.setImage(activeOrNot, for: .normal)
    }
    // метод открытия нужной картинки в потоке через сегвей
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //проверяем идентификатор сегвея, поскольку может быть больше одного
        if segue.identifier == showSingleImageSegueIdentifier {
            //делаем преобразования типа для свойства .destination в ожидаемое для нас SingleImageViewContoller
            let viewController = segue.destination as! SingleImageViewContoller
            //делаем преобразования типа для sender, если там будет что то другое - мы не сможем сконфигурировать переход
            let indexPath = sender as! IndexPath
            //получаем индекс картинки и саму картинку из ресурсов
            let image = UIImage(named: photosName[indexPath.row])
            //передаем картинку внутри SingleImageViewContoller
            viewController.image = image
        } else {
            // если неизвестный сегвей - передаем управление ему
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
    }
    
    
}
//MARK: Extensions
// создал расширение нашего класса для использования протокола UITableViewDelegate
extension ImageListViewController: UITableViewDelegate {
    //метод отвечает за действия, которые будут выполнены при тапе по ячейке таблицы
    //адрес ячейки который хранится в indexPath передается в качестве аргумента
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //выполняем переход сегвей из общего потока в конкретное фото
        // 1 аргумент - идентификатор, который мы задали в storyboard; 2 используется в override func prepare
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    //метод который отвечает за высоту ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    //метод создания ячейки, наполнением ее данными и передачи в таблицу
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
}
