import Foundation

public enum Sex: String, Codable, CaseIterable, Sendable {
    case buck
    case doe
    case unknown

    public var displayName: String {
        switch self {
        case .buck: return "Buck"
        case .doe: return "Doe"
        case .unknown: return "Unknown"
        }
    }
}

public struct EvansAnimal: Equatable, Sendable {
    public var name: String
    public var sex: Sex
    public var color: String?
    public var earNumber: String?
    public var registrationNumber: String?
    public var weightOunces: Int?
    public var grandChampion: String?
    public var legs: Int?
    public var dateOfBirth: Date?
    public var gridColumn: Int
    public var gridRow: Int

    public init(
        name: String,
        sex: Sex,
        color: String? = nil,
        earNumber: String? = nil,
        registrationNumber: String? = nil,
        weightOunces: Int? = nil,
        grandChampion: String? = nil,
        legs: Int? = nil,
        dateOfBirth: Date? = nil,
        gridColumn: Int = 0,
        gridRow: Int = 0
    ) {
        self.name = name
        self.sex = sex
        self.color = color
        self.earNumber = earNumber
        self.registrationNumber = registrationNumber
        self.weightOunces = weightOunces
        self.grandChampion = grandChampion
        self.legs = legs
        self.dateOfBirth = dateOfBirth
        self.gridColumn = gridColumn
        self.gridRow = gridRow
    }

    public var isPlaceholder: Bool {
        (earNumber?.isEmpty ?? true) && name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

public struct EvansPedigreeDocument: Equatable, Sendable {
    public var rabbitryName: String?
    public var breed: String?
    public var ownerName: String?
    public var ownerAddress: String?
    public var ownerEmail: String?
    public var animals: [EvansAnimal]
    public var exportVariant: String?

    public init(
        rabbitryName: String? = nil,
        breed: String? = nil,
        ownerName: String? = nil,
        ownerAddress: String? = nil,
        ownerEmail: String? = nil,
        animals: [EvansAnimal] = [],
        exportVariant: String? = nil
    ) {
        self.rabbitryName = rabbitryName
        self.breed = breed
        self.ownerName = ownerName
        self.ownerAddress = ownerAddress
        self.ownerEmail = ownerEmail
        self.animals = animals
        self.exportVariant = exportVariant
    }

    public var subject: EvansAnimal? {
        animals.first { $0.gridColumn == 0 }
    }
}

public enum EvansImportError: Error, Equatable {
    case fileNotFound
    case encodingDetectionFailed
    case notAnEvansFile
    case malformedDocument(reason: String)
}
