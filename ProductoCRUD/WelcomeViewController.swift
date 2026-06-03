import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var iniciarButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        
        logoImageView.layer.cornerRadius = logoImageView.frame.size.width / 2
        logoImageView.clipsToBounds = true
        
        iniciarButton.layer.cornerRadius = 12
        iniciarButton.backgroundColor = UIColor(red: 0.0, green: 0.29, blue: 0.53, alpha: 1.0)
        iniciarButton.tintColor = .white
        
        iniciarButton.layer.shadowColor = UIColor.black.cgColor
        iniciarButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        iniciarButton.layer.shadowRadius = 4
        iniciarButton.layer.shadowOpacity = 0.15
        iniciarButton.layer.masksToBounds = false
    }
}
