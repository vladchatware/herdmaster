#if canImport(SwiftUI) && canImport(SwiftData)
import Foundation
import SwiftData

enum RabbitSex: String, Codable, CaseIterable {
    case buck
    case doe
    case unknown

    var displayName: String {
        switch self {
        case .buck: return "Buck"
        case .doe: return "Doe"
        case .unknown: return "Unknown"
        }
    }
}

enum AnimalStatus: String, Codable, CaseIterable {
    case active
    case inactive
    case sold
    case deceased
}

@Model
final class Animal {
    var id: UUID = UUID()
    var earNumber: String = ""
    var name: String?
    var breed: String?
    var color: String?
    var sexRaw: String = Sex.unknown.rawValue
    var statusRaw: String = AnimalStatus.active.rawValue
    var dateOfBirth: Date?
    var weightOunces: Int?
    var registrationNumber: String?
    var grandChampion: String?
    var legs: Int?
    var notes: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var authorDeviceID: String?

    var sire: Animal?
    var dam: Animal?

    @Relationship(deleteRule: .nullify, inverse: \Animal.sire)
    var offspringAsSire: [Animal]? = []

    @Relationship(deleteRule: .nullify, inverse: \Animal.dam)
    var offspringAsDam: [Animal]? = []

    @Relationship(deleteRule: .cascade, inverse: \BreedingRecord.doe)
    var breedingRecords: [BreedingRecord]? = []

    var sex: Sex {
        get { Sex(rawValue: sexRaw) ?? .unknown }
        set { sexRaw = newValue.rawValue }
    }

    var status: AnimalStatus {
        get { AnimalStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    init(
        earNumber: String,
        name: String? = nil,
        breed: String? = nil,
        color: String? = nil,
        sex: Sex = .unknown,
        dateOfBirth: Date? = nil
    ) {
        self.id = UUID()
        self.earNumber = earNumber
        self.name = name
        self.breed = breed
        self.color = color
        self.sexRaw = sex.rawValue
        self.dateOfBirth = dateOfBirth
        self.createdAt = Date()
        self.updatedAt = Date()
        self.authorDeviceID = DeviceIdentity.shared.id
    }
}

final class DeviceIdentity: @unchecked Sendable {
    static let shared = DeviceIdentity()
    let id: String

    private init() {
        let key = "hm.device.id"
        if let existing = UserDefaults.standard.string(forKey: key) {
            self.id = existing
        } else {
            let new = UUID().uuidString
            UserDefaults.standard.set(new, forKey: key)
            self.id = new
        }
    }
}
#endif
