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

    func numberOfSections(in tableView: UITableView) -> Int {
        return productosFiltrados.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let producto = productosFiltrados[indexPath.section]
        
        cell.textLabel?.text = producto.nombre
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        let categoria = producto.categoria ?? ""
        let precio = String(format: "S/ %.2f", producto.precio)
        let stock = producto.stock
        
        let part1 = "Categoría: \(categoria)  "
        let part2 = "Precio: \(precio)"
        let part3 = "  Stock: \(stock)"
        let fullText = "\(part1)\(part2)\(part3)"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        let grayAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        let bluePremiumAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.0, green: 0.29, blue: 0.53, alpha: 1.0),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]
        
        attributedString.addAttributes(grayAttributes, range: NSRange(location: 0, length: fullText.count))
        let rangePrecio = (fullText as NSString).range(of: part2)
        if rangePrecio.location != NSNotFound {
            attributedString.addAttributes(bluePremiumAttributes, range: rangePrecio)
        }
        
        cell.detailTextLabel?.attributedText = attributedString
        
        cell.backgroundColor = .clear
        
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.shadowColor = UIColor.black.cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.contentView.layer.shadowRadius = 4
        cell.contentView.layer.shadowOpacity = 0.1
        cell.contentView.layer.masksToBounds = false
        
        cell.accessoryType = .none
        cell.imageView?.image = UIImage(systemName: "tag.fill")
        cell.imageView?.tintColor = UIColor(red: 0.0, green: 0.29, blue: 0.53, alpha: 1.0)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productosFiltrados[indexPath.section]
        performSegue(withIdentifier: "segueToDetail", sender: productoSeleccionado)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contexto = conexion()
            let producto = productosFiltrados[indexPath.section]
            contexto.delete(producto)
            do {
                try contexto.save()
                if let index = productos.firstIndex(of: producto) {
                    productos.remove(at: index)
                }
                productosFiltrados.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
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
