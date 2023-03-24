import UIKit
import Kingfisher



protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func didFetchProfile(profile: Profile)
    func didUpdateAvatar(image: UIImage)
    func present(alert: UIAlertController)
}
final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    //MARK: Свойства профильного экрана
    weak var presenter: ProfileViewPresenterProtocol?
    private var profilePictureView: UIImageView?
    private var fullName: UILabel?
    private var nickName: UILabel?
    private var profileDescription: UILabel?
    private var exitButton: UIButton?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfilePage()
        presenter?.viewDidLoad()
        }
    
   
    //MARK: Функции по созданию профильного экрана
    private func createProfilePicture() {
        
        let profilePicture = UIImage(named: "profilePhoto")
        let profilePictureView = UIImageView(image: profilePicture)
        self.profilePictureView = profilePictureView
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePictureView)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height / 2
        NSLayoutConstraint.activate([
            profilePictureView.widthAnchor.constraint(equalToConstant: 70),
            profilePictureView.heightAnchor.constraint(equalToConstant: 70),
            profilePictureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePictureView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
    }
    
    func didUpdateAvatar(image: UIImage) {
        profilePictureView?.image = image
    }
    
    private func createProfileDescription() {
        
        guard let profilePictureView = profilePictureView  else { return }
        
        let fullName = UILabel()
        self.fullName = fullName
        fullName.font = .systemFont(ofSize: 23, weight: .bold)
        fullName.text = "Ermolaev Grigoriy"
        
        fullName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        fullName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullName)
        
        let nickName = UILabel()
        self.nickName = nickName
        nickName.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        nickName.font = UIFont(name: "System Font Regular", size: 13)
        nickName.text = "@ermlvgrsh"
        nickName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickName)
        
        let profileDescription = UILabel()
        self.profileDescription = profileDescription
        profileDescription.textColor = UIColor.white
        profileDescription.font = UIFont(name: "System Font Regular", size: 13)
        profileDescription.text = " "
        profileDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileDescription)
        
        NSLayoutConstraint.activate([
            fullName.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 8),
            fullName.leadingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nickName.leadingAnchor.constraint(equalTo: fullName.leadingAnchor),
            nickName.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 8),
            
            profileDescription.leadingAnchor.constraint(equalTo: fullName.leadingAnchor),
            profileDescription.topAnchor.constraint(equalTo: nickName.bottomAnchor, constant: 8)
        ])
    }
    func didFetchProfile(profile: Profile) {
        self.fullName?.text = profile.name
        self.profileDescription?.text = profile.bio
        self.nickName?.text = profile.username
    }

    
    private func createExitButton() {
        
        createProfilePicture()
        guard let profilePictureView = profilePictureView else { return }
        guard let exitButtonImage = UIImage(named: "ipad.and.arrow.forward") else { return }
        let exitButton = UIButton.systemButton(with: exitButtonImage,
                                               target: self, action: #selector(logout))
        self.exitButton = exitButton
        exitButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        exitButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 20),
            exitButton.heightAnchor.constraint(equalToConstant: 22),
            exitButton.centerYAnchor.constraint(equalTo: profilePictureView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26)
        ])
        
    }
    func present(alert: UIAlertController) {
        present(alert, animated: true)
    }

    @objc
     func logout() {
        presenter?.logout()
    }

    private func makeProfilePage() {
        createExitButton()
        createProfileDescription()
        view.backgroundColor = UIColor(named: "black")
        
    }

}
extension ProfileViewController {
    func updateProfileDetails(profile: Profile) {
        self.profileDescription?.text = profile.bio
        self.fullName?.text = profile.name
        self.nickName?.text = profile.loginName
    }
}
