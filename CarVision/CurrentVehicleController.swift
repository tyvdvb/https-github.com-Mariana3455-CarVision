import UIKit

class CurrentVehicleController: UIViewController {

    @IBOutlet private weak var carImage: UIImageView!
    @IBOutlet private weak var carName: UILabel!
    @IBOutlet private weak var carModel: UILabel!
    @IBOutlet private weak var saveCarInfoButton: UIButton!
    
    var recognizedCarModel: String?
    var recognizedCarImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        carModel.text = recognizedCarModel
        carImage.image = recognizedCarImage
        let carDataParser = CarDataParser()
        carDataParser.fetchAndParseCSVs()
    }
    
    @IBAction func saveCarInfoButtonTapped(_ sender: UIButton) {
        guard let carModel = recognizedCarModel, let carImage = recognizedCarImage else { return }
        UserDefaults.standard.set(carModel, forKey: "savedCarModel")

        if let imageData = carImage.pngData() {
            UserDefaults.standard.set(imageData, forKey: "savedCarImage")
        }

        showAlert(title: "Success", message: "Car information saved successfully.")
        saveCarInfoButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

   
}
