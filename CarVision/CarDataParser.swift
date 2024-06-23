import Foundation

class CarDataParser {
    let csvFileNames: [String] = [
        "car_data2.csv"
    ]

    var targetMake: String
    var targetModel: String
    var targetYear: Int
    var carDetails: [String: String]?

    init(targetMake: String, targetModel: String, targetYear: Int) {
        self.targetMake = targetMake
        self.targetModel = targetModel
        self.targetYear = targetYear
    }

    func fetchAndParseCSVs() {
        for csvFileName in csvFileNames {
            guard let fileURL = Bundle.main.url(forResource: csvFileName, withExtension: nil) else {
                print("File not found: \(csvFileName)")
                continue
            }
            
            readCSV(from: fileURL)
        }
    }

    func readCSV(from fileURL: URL) {
        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            parseCSV(data: csvContent)
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
        }
    }

    private func parseCSV(data: String) {
        let rows = data.components(separatedBy: .newlines)
        guard let header = rows.first?.components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) else {
            print("Invalid CSV format: No header row found")
            return
        }
        
        let dataRows = rows.dropFirst()
        var foundExactMatch = false
        var closestMatch: [String: String]?
        var closestYearDifference = Int.max
        
        for row in dataRows {
            let columns = row.components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            var details = [String: String]()
            
            for (index, column) in columns.enumerated() {
                if index < header.count {
                    details[header[index]] = column
                }
            }
            
            if let make = details["Make"], let model = details["Model"], let yearString = details["Year"], let year = Int(yearString) {
                if make == targetMake {
                    if model.contains(targetModel) || targetModel.contains(model) {
                        let yearDifference = abs(year - targetYear)
                        if yearDifference < closestYearDifference {
                            closestYearDifference = yearDifference
                            closestMatch = details
                        }
                    }
                }
            }
        }
        
        if let closestMatch = closestMatch {
            carDetails = closestMatch
            foundExactMatch = true
        }
        
        if !foundExactMatch {
            print("Car details not found for \(targetMake) \(targetModel) \(targetYear)")
        }
    }
}
