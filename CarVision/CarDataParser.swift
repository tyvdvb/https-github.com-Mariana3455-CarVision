import Foundation

class CarDataParser {
    let csvFileNames: [String] = [
        "/Users/marianadekhtiarenko/Desktop/CarVision/CarVision/CarData/car_data1.csv",
        "CarData/car_data2",
        "CarData/car_data3"
    ]
    
    func fetchAndParseCSVs() {
        for csvFileName in csvFileNames {
            guard let filePath = Bundle.main.path(forResource: csvFileName, ofType: nil) else {
                print("File not found: \(csvFileName)")
                continue
            }
            
            readCSV(from: filePath)
        }
    }
    
    private func readCSV(from filePath: String) {
        do {
            let data = try String(contentsOfFile: filePath, encoding: .utf8)
            parseCSV(data: data)
        } catch {
            print("Error reading CSV from \(filePath): \(error.localizedDescription)")
        }
    }
    
    private func parseCSV(data: String) {
        let rows = data.split(separator: "\n")
        let header = rows.first?.split(separator: ",") ?? []
        let dataRows = rows.dropFirst()
        
        for row in dataRows {
            let columns = row.split(separator: ",")
            var details = [String: String]()
            
            for (index, column) in columns.enumerated() {
                if index < header.count {
                    details[String(header[index])] = String(column)
                }
            }
            
            if let modelName = details["ModelName"], modelName == "YourCarModel" { // Replace "YourCarModel" with the actual model name you are looking for
                printCarDetails(details)
            }
        }
    }
    
    private func printCarDetails(_ details: [String: String]) {
        if let fuelType = details["FuelType"] {
            print("Fuel Type: \(fuelType)")
        }
        if let drive = details["Drive"] {
            print("Drive: \(drive)")
        }
        if let transmission = details["Transmission"] {
            print("Transmission: \(transmission)")
        }
        if let cityMpg = details["CityMPG"] {
            print("City MPG: \(cityMpg)")
        }
    }
}


