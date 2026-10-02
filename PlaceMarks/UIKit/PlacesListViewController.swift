import UIKit

protocol PlacesListDelegate: AnyObject {
    func placesList(_ controller: PlacesListViewController, didSelect location: MapLocation)
    func placesList(_ controller: PlacesListViewController, didDelete location: MapLocation)

}

final class PlacesListViewController: UIViewController {
    private let tableView = UITableView()
    private var locations: [MapLocation]
    weak var delegate: PlacesListDelegate?

    init(locations: [MapLocation], delegate: PlacesListDelegate? = nil) {
        self.locations = locations
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Places"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func update(locations: [MapLocation]) {
        self.locations = locations
        tableView.reloadData()
    }
}

extension PlacesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let location = locations[indexPath.row]
        config.text = location.name
        config.secondaryText = location.description.isEmpty ? "No description" : location.description
        cell.contentConfiguration = config
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let removed = locations[indexPath.row]
        locations.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        delegate?.placesList(self, didDelete: removed)
    }
}

extension PlacesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.placesList(self, didSelect: locations[indexPath.row])
    }
}
