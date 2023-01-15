import UIKit

class ProfileViewController: UIViewController {
    
    
    var profilePictureView: UIImageView?
    var fullName: UILabel?
    var nickName: UILabel?
    var profileDescription: UILabel?
    var exitButton: UIButton?
    
    private func createProfilePicture() {
        
        let profilePicture = UIImage(named: "profilePhoto")
        let profilePictureView = UIImageView(image: profilePicture)
        self.profilePictureView = profilePictureView
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePictureView)
        
        NSLayoutConstraint.activate([
            profilePictureView.widthAnchor.constraint(equalToConstant: 70),
            profilePictureView.heightAnchor.constraint(equalToConstant: 70),
            profilePictureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePictureView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            
        ])
        
    }
    private func createProfileDescription() {
        
        guard let profilePictureView = profilePictureView  else { return }
        
        let fullName = UILabel()
        self.fullName = fullName
        fullName.font = .systemFont(ofSize: 23, weight: .bold)
        fullName.text = "Екатерина Новикова"
       
        fullName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        fullName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullName)
        
        let nickName = UILabel()
        self.nickName = nickName
        nickName.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        nickName.font = UIFont(name: "System Font Regular", size: 13)
        nickName.text = "@ekaterina_nov"
        nickName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickName)
        
        let profileDescription = UILabel()
        self.profileDescription = profileDescription
        profileDescription.textColor = UIColor.white
        profileDescription.font = UIFont(name: "System Font Regular", size: 13)
        profileDescription.text = "Hello, World!"
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
    private func createExitButton() {
        
       createProfilePicture()
        guard let profilePictureView = profilePictureView else { return }
        guard let exitButtonImage = UIImage(named: "ipad.and.arrow.forward") else { return }
        let exitButton = UIButton.systemButton(with: exitButtonImage,
                                               target: self,
                                               action: .none)
        self.exitButton = exitButton
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
    private func makeProfilePage() {
        createExitButton()
        createProfileDescription()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfilePage()
    }
    
    //MARK: Profile Outlets

   
    
    //MARK: Profile Action

    
    
    
    
}
