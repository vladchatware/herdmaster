#if canImport(SwiftUI) && canImport(SwiftData)
import Foundation
import SwiftData

enum BreedingStage: String, Codable, CaseIterable {
    case bred
    case palpation
    case nestBox
    case kindling
    case weaning
    case rebreed
}

@Model
final class BreedingRecord {
    var id: UUID = UUID()
    var breedingDate: Date = Date()
    var expectedKindlingDate: Date?
    var actualKindlingDate: Date?
    var palpationDate: Date?
    var palpationResult: String?
    var nestBoxDate: Date?
    var weaningDate: Date?
    var kitCount: Int = 0
    var liveKitCount: Int = 0
    var stageRaw: String = BreedingStage.bred.rawValue
    var notes: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var authorDeviceID: String?

    var doe: Animal?
    var buck: Animal?

    var stage: BreedingStage {
        get { BreedingStage(rawValue: stageRaw) ?? .bred }
        set { stageRaw = newValue.rawValue }
    }

    init(doe: Animal, buck: Animal, breedingDate: Date = Date()) {
        self.id = UUID()
        self.doe = doe
        self.buck = buck
        self.breedingDate = breedingDate
        self.expectedKindlingDate = Calendar.current.date(byAdding: .day, value: 31, to: breedingDate)
        self.stageRaw = BreedingStage.bred.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.authorDeviceID = DeviceIdentity.shared.id
    }
}
#endif
