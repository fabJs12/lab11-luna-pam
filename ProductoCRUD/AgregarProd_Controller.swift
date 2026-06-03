import UIKit
import CoreData

class AgregarProd_Controller: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var precioTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var categoriaTextField: UITextField!
    @IBOutlet weak var guardarButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        
        estilizarTextField(nombreTextField)
        estilizarTextField(precioTextField)
        estilizarTextField(stockTextField)
        estilizarTextField(categoriaTextField)
        
        precioTextField.keyboardType = .decimalPad
        precioTextField.delegate = self
        stockTextField.keyboardType = .numberPad
        stockTextField.delegate = self
        
        guardarButton.layer.cornerRadius = 12
        guardarButton.backgroundColor = UIColor(red: 0.0, green: 0.29, blue: 0.53, alpha: 1.0)
        guardarButton.tintColor = .white
        guardarButton.layer.shadowColor = UIColor.black.cgColor
        guardarButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        guardarButton.layer.shadowRadius = 4
        guardarButton.layer.shadowOpacity = 0.15
        guardarButton.layer.masksToBounds = false
    }
    
    func estilizarTextField(_ tf: UITextField) {
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1.0
        tf.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        tf.clipsToBounds = true
    }
    
    func conexion() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    @IBAction func guardarTapped(_ sender: UIButton) {
        let nombre = (nombreTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let precioRaw = (precioTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let stockRaw = (stockTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let categoria = (categoriaTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !nombre.isEmpty else {
            print("Error: El campo nombre está vacío")
            return
        }
        
        guard !precioRaw.isEmpty else {
            print("Error: El campo precio está vacío")
            return
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        var precioDouble: Double? = formatter.number(from: precioRaw)?.doubleValue
        if precioDouble == nil {
            let cleanDot = precioRaw.replacingOccurrences(of: ",", with: ".")
            precioDouble = Double(cleanDot)
        }
        
        guard let precio = precioDouble else {
            print("Error: El campo precio no es un número válido")
            return
        }
        
        guard !stockRaw.isEmpty else {
            print("Error: El campo stock está vacío")
            return
        }
        
        var stockDouble: Double? = formatter.number(from: stockRaw)?.doubleValue
        if stockDouble == nil {
            let cleanDot = stockRaw.replacingOccurrences(of: ",", with: ".")
            stockDouble = Double(cleanDot)
        }
        
        guard let stockVal = stockDouble, stockVal >= Double(Int16.min), stockVal <= Double(Int16.max) else {
            print("Error: El campo stock no es un número entero de 16 bits válido")
            return
        }
        let stock = Int16(stockVal)
        
        guard !categoria.isEmpty else {
            print("Error: El campo categoría está vacío")
            return
        }
        
        let contexto = conexion()
        let nuevoProducto = Producto(context: contexto)
        nuevoProducto.nombre = nombre
        nuevoProducto.precio = precio
        nuevoProducto.stock = stock
        nuevoProducto.categoria = categoria
        
        do {
            try contexto.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al guardar: \(error)")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if textField.keyboardType == .numberPad {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        } else if textField.keyboardType == .decimalPad {
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            let currentText = textField.text ?? ""
            if (string == "." || string == ",") && (currentText.contains(".") || currentText.contains(",")) {
                return false
            }
            return true
        }
        return true
    }
}
