import UIKit

final class SingleImageViewContoller: UIViewController, UIScrollViewDelegate {
    //добавляем новое свойство для SingleviewController, которое будет показывать картинки не инициирую загрузку view
    var image: UIImage! {
        //вводим наблюдателя для проверки
        didSet {
            // проверяем было ли ранее загружено вью - эта проверка не даст нам закрашиться в prepareForSegue
            guard isViewLoaded else { return }
            //сюда попадать мы не должны. Можем сюда попать например, если был показан SVC, а указатель на него запомнен извне. Извне - в него проставляется новое изображение
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    
    @IBAction private func didTapShareButton() {
        
        guard let image = image else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    //метод который реализует делегат UIScrollView и позволяет зумировать фотографию
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    //метод который изменяет размер фото под экран(рескейлит) и размещает ее по центру
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    
    //    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        view.layoutIfNeeded()
//        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
//        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
//        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
//    }
    
    
}



