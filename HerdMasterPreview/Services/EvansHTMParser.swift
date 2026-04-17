import Foundation

struct EvansAnimal {
    var name: String
    var sex: Sex
    var color: String?
    var earNumber: String?
    var registrationNumber: String?
    var weightOunces: Int?
    var grandChampion: String?
    var legs: Int?
    var dateOfBirth: Date?
    var gridColumn: Int
    var gridRow: Int

    var isPlaceholder: Bool {
        earNumber?.isEmpty ?? true && name.isEmpty
    }
}

struct EvansPedigreeDocument {
    var rabbitryName: String?
    var breed: String?
    var ownerName: String?
    var ownerAddress: String?
    var ownerEmail: String?
    var animals: [EvansAnimal]
    var exportVariant: String?

    var subject: EvansAnimal? {
        animals.first { $0.gridColumn == 1 }
    }
}

enum EvansImportError: Error, Equatable {
    case fileNotFound
    case encodingDetectionFailed
    case notAnEvansFile
    case malformedDocument(reason: String)
}

final class EvansHTMParser {

    func parse(fileAt url: URL) throws -> EvansPedigreeDocument {
        let data = try Data(contentsOf: url)
        let html = try decodeWithFallback(data: data)
        return try parse(html: html)
    }

    func parse(html rawHTML: String) throws -> EvansPedigreeDocument {
        guard rawHTML.contains("Rabbit Register by Evans Software")
                || rawHTML.lowercased().contains("evsoft.us") else {
            throw EvansImportError.notAnEvansFile
        }

        let normalized = normalizeEntities(rawHTML)

        let rabbitryName = extractRabbitryName(from: normalized)
        let breed = extractBreed(from: normalized)
        let (ownerName, ownerAddress, ownerEmail) = extractOwner(from: normalized)
        let exportVariant = extractExportVariant(from: normalized)

        let animals = extractAnimals(from: normalized)

        return EvansPedigreeDocument(
            rabbitryName: rabbitryName,
            breed: breed,
            ownerName: ownerName,
            ownerAddress: ownerAddress,
            ownerEmail: ownerEmail,
            animals: animals,
            exportVariant: exportVariant
        )
    }

    private func decodeWithFallback(data: Data) throws -> String {
        let encodings: [String.Encoding] = [.utf8, .windowsCP1252, .isoLatin1]
        for encoding in encodings {
            if let decoded = String(data: data, encoding: encoding) {
                return decoded
            }
        }
        throw EvansImportError.encodingDetectionFailed
    }

    private func normalizeEntities(_ html: String) -> String {
        var result = html
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "\u{00A0}", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        return result
    }

    private func extractRabbitryName(from html: String) -> String? {
        let pattern = #"<h1>([^<]+)</h1>"#
        return firstCapture(pattern: pattern, in: html)?.trimmingCharacters(in: .whitespaces)
    }

    private func extractBreed(from html: String) -> String? {
        let pattern = #"<h1>([^<]+)Pedigree</h1>"#
        return firstCapture(pattern: pattern, in: html)?
            .replacingOccurrences(of: "Pedigree", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    private func extractOwner(from html: String) -> (name: String?, address: String?, email: String?) {
        let emailPattern = #"mailto:([^""]+)"#
        let email = firstCapture(pattern: emailPattern, in: html)

        let lines = html.components(separatedBy: "<BR>")
        var ownerName: String?
        var ownerAddress: String?

        for (index, line) in lines.enumerated() {
            let cleaned = stripTags(line).trimmingCharacters(in: .whitespaces)
            if cleaned.contains(",") && cleaned.lowercased().contains("crawford") {
                ownerName = cleaned
                if index + 2 < lines.count {
                    let addressLine = stripTags(lines[index + 1]).trimmingCharacters(in: .whitespaces)
                    let cityStateLine = stripTags(lines[index + 2]).trimmingCharacters(in: .whitespaces)
                    ownerAddress = "\(addressLine), \(cityStateLine)"
                }
                break
            }
        }

        return (ownerName, ownerAddress, email)
    }

    private func extractExportVariant(from html: String) -> String? {
        let pattern = #"<Title>\s*([^<]+)\s*</Title>"#
        return firstCapture(pattern: pattern, in: html)?.trimmingCharacters(in: .whitespaces)
    }

    private func extractAnimals(from html: String) -> [EvansAnimal] {
        var animals: [EvansAnimal] = []

        let cellPattern = #"<TD\s+rowspan\s*=\s*"(\d+)"\s+class\s*=\s*"(male|female|neuter)"[^>]*>(.*?)</TD>"#
        guard let regex = try? NSRegularExpression(
            pattern: cellPattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ) else {
            return animals
        }

        let ns = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: ns.length))

        var currentColumn = 0
        var currentRow = 0

        for match in matches {
            let classString = ns.substring(with: match.range(at: 2)).lowercased()
            let contents = ns.substring(with: match.range(at: 3))

            let sex: Sex
            switch classString {
            case "male": sex = .buck
            case "female": sex = .doe
            default: sex = .unknown
            }

            let animal = parseAnimalCell(contents: contents, sex: sex, column: currentColumn, row: currentRow)
            animals.append(animal)

            currentRow += 1
            if currentRow >= pow2AtColumn(currentColumn) {
                currentColumn += 1
                currentRow = 0
            }
        }

        return animals.filter { !$0.isPlaceholder }
    }

    private func pow2AtColumn(_ col: Int) -> Int {
        return 1 << col
    }

    private func parseAnimalCell(contents: String, sex: Sex, column: Int, row: Int) -> EvansAnimal {
        let clean = stripTags(contents)
        let lines = clean
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let name = lines.first ?? ""
        let color = lines.count > 1 ? lines[1] : nil

        let earNumber = extractField(pattern: #"Ear\s*#\s*:\s*(\S+)"#, from: clean)
        let regNumber = extractField(pattern: #"Reg\s*#\s*:\s*(\S+)"#, from: clean)
        let weightOunces = extractWeight(from: clean)
        let gc = extractField(pattern: #"GC\s*:\s*(\S+)"#, from: clean)
        let legs = extractField(pattern: #"Legs\s*:\s*(\d+)"#, from: clean).flatMap { Int($0) }
        let dob = extractDate(from: clean)

        return EvansAnimal(
            name: name,
            sex: sex,
            color: color,
            earNumber: earNumber,
            registrationNumber: regNumber,
            weightOunces: weightOunces,
            grandChampion: gc,
            legs: legs,
            dateOfBirth: dob,
            gridColumn: column,
            gridRow: row
        )
    }

    private func extractWeight(from text: String) -> Int? {
        let pattern = #"Weight\s*:\s*(\d+)\s*#\s*(\d+)?\s*oz?"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let ns = text as NSString
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)) else {
            return nil
        }

        let pounds = Int(ns.substring(with: match.range(at: 1))) ?? 0
        let ouncesRange = match.range(at: 2)
        let ounces = ouncesRange.location != NSNotFound
            ? (Int(ns.substring(with: ouncesRange)) ?? 0)
            : 0

        return pounds * 16 + ounces
    }

    private func extractDate(from text: String) -> Date? {
        let pattern = #"DOB\s*:\s*([A-Za-z]+\s+\d+,\s+\d{4})"#
        guard let dateString = firstCapture(pattern: pattern, in: text) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.date(from: dateString.trimmingCharacters(in: .whitespaces))
    }

    private func extractField(pattern: String, from text: String) -> String? {
        firstCapture(pattern: pattern, in: text)?.trimmingCharacters(in: .whitespaces)
    }

    private func firstCapture(pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return nil
        }
        let ns = text as NSString
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)),
              match.numberOfRanges > 1,
              match.range(at: 1).location != NSNotFound else {
            return nil
        }
        return ns.substring(with: match.range(at: 1))
    }

    private func stripTags(_ html: String) -> String {
        var result = html
        let tagPattern = #"<[^>]+>"#
        if let regex = try? NSRegularExpression(pattern: tagPattern) {
            let ns = result as NSString
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(location: 0, length: ns.length),
                withTemplate: "\n"
            )
        }
        return result
    }
}
