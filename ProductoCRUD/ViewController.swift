import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tablaProductos: UITableView!

    var productos = [Producto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tablaProductos.delegate = self
        tablaProductos.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        leerProductos()
    }

    func conexion() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    func leerProductos() {
        let contexto = conexion()
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        do {
            productos = try contexto.fetch(fetchRequest)
            tablaProductos.reloadData()
        } catch {
            print("Error al leer productos: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let producto = productos[indexPath.row]
        cell.textLabel?.text = producto.nombre
        let categoria = producto.categoria ?? ""
        let precio = String(format: "S/ %.2f", producto.precio)
        let stock = producto.stock
        cell.detailTextLabel?.text = "Categoría: \(categoria) - Precio: \(precio) - Stock: \(stock)"
        
        cell.layer.cornerRadius = 12
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.1
        cell.layer.masksToBounds = false
        
        return cell
    }

    @IBAction func agregarProducto(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Nuevo Producto", message: "Ingrese los datos del producto", preferredStyle: .alert)
        
        alerta.addTextField { (tf) in
            tf.placeholder = "Nombre"
        }
        alerta.addTextField { (tf) in
            tf.placeholder = "Precio"
            tf.keyboardType = .decimalPad
            tf.delegate = self
        }
        alerta.addTextField { (tf) in
            tf.placeholder = "Stock"
            tf.keyboardType = .numberPad
            tf.delegate = self
        }
        alerta.addTextField { (tf) in
            tf.placeholder = "Categoría"
        }
        
        let accionGuardar = UIAlertAction(title: "Guardar", style: .default) { _ in
            let nombre = (alerta.textFields?[0].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let precioRaw = (alerta.textFields?[1].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let stockRaw = (alerta.textFields?[2].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let categoria = (alerta.textFields?[3].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
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
            
            guard let stock = Int16(stockRaw) else {
                print("Error: El campo stock no es un número entero de 16 bits válido")
                return
            }
            
            guard !categoria.isEmpty else {
                print("Error: El campo categoría está vacío")
                return
            }
            
            let contexto = self.conexion()
            let nuevoProducto = Producto(context: contexto)
            nuevoProducto.nombre = nombre
            nuevoProducto.precio = precio
            nuevoProducto.stock = stock
            nuevoProducto.categoria = categoria
            
            do {
                try contexto.save()
                DispatchQueue.main.async {
                    self.leerProductos()
                    self.tablaProductos.reloadData()
                }
            } catch {
                print("Error al guardar: \(error)")
            }
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alerta.addAction(accionGuardar)
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contexto = conexion()
            let producto = productos[indexPath.row]
            contexto.delete(producto)
            do {
                try contexto.save()
                productos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error al borrar: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let producto = productos[indexPath.row]
        let alerta = UIAlertController(title: "Editar Producto", message: "Actualice los datos del producto", preferredStyle: .alert)
        
        alerta.addTextField { (tf) in
            tf.text = producto.nombre
            tf.placeholder = "Nombre"
        }
        alerta.addTextField { (tf) in
            tf.text = String(producto.precio)
            tf.placeholder = "Precio"
            tf.keyboardType = .decimalPad
            tf.delegate = self
        }
        alerta.addTextField { (tf) in
            tf.text = String(producto.stock)
            tf.placeholder = "Stock"
            tf.keyboardType = .numberPad
            tf.delegate = self
        }
        alerta.addTextField { (tf) in
            tf.text = producto.categoria
            tf.placeholder = "Categoría"
        }
        
        let accionActualizar = UIAlertAction(title: "Actualizar", style: .default) { _ in
            let nombre = (alerta.textFields?[0].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let precioRaw = (alerta.textFields?[1].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let stockRaw = (alerta.textFields?[2].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let categoria = (alerta.textFields?[3].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
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
            
            guard let stock = Int16(stockRaw) else {
                print("Error: El campo stock no es un número entero de 16 bits válido")
                return
            }
            
            guard !categoria.isEmpty else {
                print("Error: El campo categoría está vacío")
                return
            }
            
            let contexto = self.conexion()
            producto.nombre = nombre
            producto.precio = precio
            producto.stock = stock
            producto.categoria = categoria
            
            do {
                try contexto.save()
                DispatchQueue.main.async {
                    self.leerProductos()
                    self.tablaProductos.reloadData()
                }
            } catch {
                print("Error al actualizar: \(error)")
            }
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alerta.addAction(accionActualizar)
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
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
