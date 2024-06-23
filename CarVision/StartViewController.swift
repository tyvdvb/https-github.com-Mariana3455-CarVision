import UIKit
import Vision
import CoreML

class StartViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var recognizeButton: UIButton!
    
    var recognizedCarModel: String?
    var recognizedCarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recognizeButton.layer.cornerRadius = 10
        recognizeButton.layer.masksToBounds = true
    }
    
    @IBAction func recognizeButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.handleSelectPhotoTap(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.handleSelectPhotoTap(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleSelectPhotoTap(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.recognizeCar(in: image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func recognizeCar(in image: UIImage) {
        guard let modelURL = Bundle.main.url(forResource: "CarsClassifier", withExtension: "mlmodelc") else {
            fatalError("Model file not found in bundle")
        }

        do {
            let model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let error = error {
                    print("Error in classification request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    return
                }
                
                if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                    let carModel = topResult.identifier
                    print("Recognized car model: \(carModel)")
                    DispatchQueue.main.async {
                        self.recognizedCarModel = carModel
                        self.recognizedCarImage = image
                        self.performSegue(withIdentifier: "showCurrentVehicle", sender: self)
                    }
                }
            }

            guard let ciImage = CIImage(image: image) else {
                fatalError("Could not convert UIImage to CIImage")
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        } catch {
            print("Failed to create VNCoreMLModel: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrentVehicle" {
            if let destinationVC = segue.destination as? CurrentVehicleController {
                destinationVC.recognizedCarModel = recognizedCarModel
                destinationVC.recognizedCarImage = recognizedCarImage
            }
        }
    }
}
