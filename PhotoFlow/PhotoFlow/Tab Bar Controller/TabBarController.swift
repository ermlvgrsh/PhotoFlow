import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController")
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter(profileService: ProfileService(), helper: ProfileHelper())
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: UIImage(named: "profile_active"),
                                                        selectedImage: nil)
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
