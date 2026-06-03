import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        }
        alerta.addTextField { (tf) in
            tf.placeholder = "Stock"
            tf.keyboardType = .numberPad
        }
        alerta.addTextField { (tf) in
            tf.placeholder = "Categoría"
        }
        
        let accionGuardar = UIAlertAction(title: "Guardar", style: .default) { _ in
            let nombre = alerta.textFields?[0].text ?? ""
            let precioText = alerta.textFields?[1].text ?? ""
            let stockText = alerta.textFields?[2].text ?? ""
            let categoria = alerta.textFields?[3].text ?? ""
            
            let contexto = self.conexion()
            let nuevoProducto = Producto(context: contexto)
            nuevoProducto.nombre = nombre
            nuevoProducto.precio = Double(precioText) ?? 0.0
            nuevoProducto.stock = Int16(stockText) ?? 0
            nuevoProducto.categoria = categoria
            
            do {
                try contexto.save()
                self.leerProductos()
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
        }
        alerta.addTextField { (tf) in
            tf.text = String(producto.stock)
            tf.placeholder = "Stock"
            tf.keyboardType = .numberPad
        }
        alerta.addTextField { (tf) in
            tf.text = producto.categoria
            tf.placeholder = "Categoría"
        }
        
        let accionActualizar = UIAlertAction(title: "Actualizar", style: .default) { _ in
            let nombre = alerta.textFields?[0].text ?? ""
            let precioText = alerta.textFields?[1].text ?? ""
            let stockText = alerta.textFields?[2].text ?? ""
            let categoria = alerta.textFields?[3].text ?? ""
            
            let contexto = self.conexion()
            producto.nombre = nombre
            producto.precio = Double(precioText) ?? 0.0
            producto.stock = Int16(stockText) ?? 0
            producto.categoria = categoria
            
            do {
                try contexto.save()
                self.leerProductos()
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
}
