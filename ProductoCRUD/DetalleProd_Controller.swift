import UIKit

class DetalleProd_Controller: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var tarjetaView: UIView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var precioLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var categoriaLabel: UILabel!
    @IBOutlet weak var editarButton: UIButton!

    var producto: Producto?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        
        tarjetaView.layer.cornerRadius = 12
        tarjetaView.backgroundColor = .white
        tarjetaView.layer.shadowColor = UIColor.black.cgColor
        tarjetaView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tarjetaView.layer.shadowRadius = 4
        tarjetaView.layer.shadowOpacity = 0.1
        tarjetaView.layer.masksToBounds = false
        
        editarButton.layer.cornerRadius = 12
        editarButton.backgroundColor = UIColor(red: 0.0, green: 0.29, blue: 0.53, alpha: 1.0)
        editarButton.tintColor = .white
        editarButton.layer.shadowColor = UIColor.black.cgColor
        editarButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        editarButton.layer.shadowRadius = 4
        editarButton.layer.shadowOpacity = 0.15
        editarButton.layer.masksToBounds = false
        
        logoImageView.image = UIImage(systemName: "box.truck.fill")
        logoImageView.tintColor = UIColor(red: 0.0, green: 0.29, blue: 0.53, alpha: 1.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mostrarDetalle()
    }

    func mostrarDetalle() {
        guard let prod = producto else { return }
        nombreLabel.text = "Nombre: \(prod.nombre ?? "")"
        precioLabel.text = String(format: "Precio: S/ %.2f", prod.precio)
        stockLabel.text = "Stock: \(prod.stock)"
        categoriaLabel.text = "Categoría: \(prod.categoria ?? "")"
    }

    @IBAction func editarTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToEdit", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEdit" {
            if let destVC = segue.destination as? EditProd_Controller {
                destVC.producto = producto
            }
        }
    }
}
