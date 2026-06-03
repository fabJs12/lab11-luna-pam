import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tablaProductos: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var productos = [Producto]()
    var productosFiltrados = [Producto]()
    var estaBuscando = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        
        tablaProductos.delegate = self
        tablaProductos.dataSource = self
        searchBar.delegate = self
        
        searchBar.placeholder = "Buscar producto..."
        searchBar.backgroundImage = UIImage()
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
            filtrarProductos(conTexto: searchBar.text ?? "")
        } catch {
            print("Error al leer productos: \(error)")
        }
    }

    func filtrarProductos(conTexto texto: String) {
        let cleanTexto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanTexto.isEmpty {
            estaBuscando = false
            productosFiltrados = productos
        } else {
            estaBuscando = true
            productosFiltrados = productos.filter { prod in
                let nombreCoincide = (prod.nombre ?? "").range(of: cleanTexto, options: .caseInsensitive) != nil
                let categoriaCoincide = (prod.categoria ?? "").range(of: cleanTexto, options: .caseInsensitive) != nil
                return nombreCoincide || categoriaCoincide
            }
        }
        tablaProductos.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtrarProductos(conTexto: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productosFiltrados.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let producto = productosFiltrados[indexPath.row]
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productosFiltrados[indexPath.row]
        performSegue(withIdentifier: "segueToDetail", sender: productoSeleccionado)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contexto = conexion()
            let producto = productosFiltrados[indexPath.row]
            contexto.delete(producto)
            do {
                try contexto.save()
                if let index = productos.firstIndex(of: producto) {
                    productos.remove(at: index)
                }
                productosFiltrados.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error al borrar: \(error)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToDetail" {
            if let destVC = segue.destination as? DetalleProd_Controller,
               let producto = sender as? Producto {
                destVC.producto = producto
            }
        }
    }
}
