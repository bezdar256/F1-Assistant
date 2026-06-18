import UIKit

class CircuitsViewController: BaseTableViewController, UITableViewDataSource {
    private let circuits = FallbackData.circuits
    override func viewDidLoad() { super.viewDidLoad(); title = "Circuits"; tableView.dataSource = self; tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId); tableView.register(RaceCardCell.self, forCellReuseIdentifier: RaceCardCell.reuseId) }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { circuits.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { let circuit = circuits[indexPath.row]; let race = FallbackData.races.first { $0.circuitId == circuit.id } ?? FallbackData.races[0]; let c = tableView.dequeueReusableCell(withIdentifier: RaceCardCell.reuseId, for: indexPath) as! RaceCardCell; c.configure(race); return c }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { let circuit = circuits[indexPath.row]; let race = FallbackData.races.first { $0.circuitId == circuit.id } ?? FallbackData.races[0]; navigationController?.pushViewController(RaceDetailViewController(race: race), animated: true) }
}
