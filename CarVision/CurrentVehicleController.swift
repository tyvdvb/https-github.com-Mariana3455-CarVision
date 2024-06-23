import UIKit

class CurrentVehicleController: UIViewController {
    
    @IBOutlet private weak var carImage: UIImageView!
    @IBOutlet private weak var carName: UILabel!
    @IBOutlet private weak var carModel: UILabel!
    @IBOutlet private weak var carTransmission: UILabel!
    @IBOutlet private weak var carNumOfDoors: UILabel!
    @IBOutlet private weak var saveCarInfoButton: UIButton!
    
    @IBOutlet weak var viewARButton: UIButton!
    var recognizedCarModel: String?
    var recognizedCarImage: UIImage?
    var carDataParser: CarDataParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carModel.text = recognizedCarModel
        carImage.image = recognizedCarImage
        
        if let carModel = recognizedCarModel {
            let components = carModel.split(separator: " ")
            if components.count >= 3 {
                let make = String(components[0])
                let model = components.dropFirst().dropLast().joined(separator: " ")
                if let year = Int(components.last!) {
                    carDataParser = CarDataParser(targetMake: make, targetModel: model, targetYear: year)
                    carDataParser?.fetchAndParseCSVs()
                    
                    if let carDetails = carDataParser?.carDetails {
                        carName.text = carDetails["Make"]
                        carTransmission.text = carDetails["Transmission Type"]
                        if let numOfDoors = carDetails["Number of Doors"] {
                            carNumOfDoors.text = "Doors: \(numOfDoors)"
                        }
                        printCarDetails(carDetails)
                    } else {
                        print("Car details not found.")
                    }
                } else {
                    print("Invalid year format in recognized car model")
                }
            } else {
                print("Invalid car model format")
            }
        }
    }
    
    @IBAction func saveCarInfoButtonTapped(_ sender: UIButton) {
        guard let carModel = recognizedCarModel, let carImage = recognizedCarImage else { return }
        UserDefaults.standard.set(carModel, forKey: "savedCarModel")
        
        if let imageData = carImage.pngData() {
            UserDefaults.standard.set(imageData, forKey: "savedCarImage")
        }
        
        if let carDetails = carDataParser?.carDetails {
            UserDefaults.standard.set(carDetails, forKey: "savedCarDetails")
        }
        
        showAlert(title: "Success", message: "Car information saved successfully.")
        saveCarInfoButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func printCarDetails(_ details: [String: String]) {
        print("Car Details:")
        for (key, value) in details {
            print("\(key): \(value)")
        }
    }
    
    
    
    @IBAction func viewARButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showARView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showARView" {
            if let destinationVC = segue.destination as? ARViewController {
                destinationVC.recognizedCarModel = recognizedCarModel
                destinationVC.recognizedCarImage = recognizedCarImage
            }
        }
    }
    
    
    
}
