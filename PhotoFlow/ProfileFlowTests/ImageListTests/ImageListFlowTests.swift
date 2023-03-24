import UIKit
@testable import PhotoFlow


final class ImageListViewPresenterSpy: ImageListViewPresenterProtocol {
    var view: PhotoFlow.ImageListViewControllerProtocol?
    var viewDidLoaded = false
    var notificationIsSet = false
    var photosNextPageIsFetched = false
    
    func viewDidLoad() {
        viewDidLoaded = true
    }
    
    func changeLikeStatus(for photo: PhotoFlow.Photo, isLiked: Bool) { }
    
    func setNotification() {
        notificationIsSet = true
    }
    
    func fetchPhotosNextPage() {
        photosNextPageIsFetched = true
    }
}

final class ImageListViewControllerSpy: ImageListViewControllerProtocol {
    var presenter: PhotoFlow.ImageListViewPresenterProtocol?
    var tableViewAnimated = false
    
    func updateTableViewAnimated() {
        presenter?.setNotification()
        tableViewAnimated = true
    }
    
    
}

import XCTest

 final class ImageListFlowTests: XCTestCase {

    func testViewControllerDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        let presenter = ImageListViewPresenterSpy()
        
        //when
        viewController.configure(presenter)
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoaded)
    }
     
     func testSettingNotification() {
         //given
         let presenter = ImageListViewPresenterSpy()
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
         viewController.configure(presenter)
         
         //when
         presenter.setNotification()
         
         //then
         XCTAssertTrue(presenter.notificationIsSet)
     }
     
     func testFetchingPhotos() {
         //given
         let presenter = ImageListViewPresenterSpy()
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
         viewController.configure(presenter)
         
         //when
         presenter.fetchPhotosNextPage()
         
         //then
         XCTAssertTrue(presenter.photosNextPageIsFetched)
         
     }
     
     func testUpdateTableView() {
         //given
         let viewController = ImageListViewControllerSpy()
         let presenter = ImageListViewPresenter()
         
         //when
         presenter.setNotification()
         
         //then
         XCTAssertTrue(viewController.tableViewAnimated)
     }
}
