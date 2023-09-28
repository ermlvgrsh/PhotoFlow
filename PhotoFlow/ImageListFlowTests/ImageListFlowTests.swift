import XCTest
import UIKit
@testable import PhotoFlow

final class ImageListPresenterSpy: ImageListViewPresenterProtocol {

    var view: PhotoFlow.ImageListViewControllerProtocol?
    var viewDidLoaded = false
    var notificationIsSet = false
    var photosNextPageIsFetched = false
    
    func viewDidLoad() {
        viewDidLoaded = true
    }
    
    func setNotification() {
        notificationIsSet = true
    }
    
    func fetchPhotosNextPage() {
        photosNextPageIsFetched = true
    }
}

final class ImageListControllerSpy: ImageListViewControllerProtocol {
    
    var presenter: PhotoFlow.ImageListViewPresenterProtocol?
    var tableViewAnimated = false
    
    func updateTableViewAnimated() {
        presenter?.setNotification()
        tableViewAnimated = true
    }
    
    
}

final class ImageListFlowTests: XCTestCase {

    func testViewDidLoaded() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        let presenter = ImageListPresenterSpy()
        viewController.configure(presenter)
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoaded)
    }
    
    func testSetNotification() {
        let presenter = ImageListPresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        viewController.configure(presenter)
        
        presenter.setNotification()
        
        XCTAssertTrue(presenter.notificationIsSet)
    }
    
    func testFetchingPhotos() {
        let presenter = ImageListPresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        
        viewController.configure(presenter)
        
        presenter.fetchPhotosNextPage()
        
        XCTAssertTrue(presenter.photosNextPageIsFetched)
    }
    
    func testUpdateTableView() {
        
        let viewContoller = ImageListViewController()
        let presenter = ImageListPresenterSpy()
        
        viewContoller.configure(presenter)
        
        presenter.setNotification()
        
        XCTAssertTrue(presenter.notificationIsSet)
    }
}
