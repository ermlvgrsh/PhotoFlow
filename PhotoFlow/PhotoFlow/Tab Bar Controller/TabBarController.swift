import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let profileViewController = setupProfileViewController()
        let imageListViewController = setupImageListViewController()
        
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
    
    private func setupProfileViewController() -> ProfileViewController {
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter(profileService: ProfileService(), helper: ProfileHelper())
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: UIImage(named: "profile_active"),
                                                        selectedImage: nil)
        return profileViewController
    }
    private func setupImageListViewController() -> ImageListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        let presenter = ImageListViewPresenter()
        imageListViewController.configure(presenter)
        return imageListViewController
    }
}
