import Foundation
import SwiftData

enum ConflictField: String, Codable {
    case kitCount
    case liveKitCount
    case breedingDate
    case actualKindlingDate
    case sire
    case dam
    case weight
    case notes
}

enum ConflictResolution: String, Codable {
    case unresolved
    case keptMine
    case keptTheirs
    case mergedFieldByField
}

@Model
final class SyncConflict {
    var id: UUID = UUID()
    var recordID: UUID = UUID()
    var recordType: String = ""
    var fieldRaw: String = ""
    var mineValue: String?
    var theirsValue: String?
    var mineAuthorDeviceID: String?
    var theirsAuthorDeviceID: String?
    var mineTimestamp: Date = Date()
    var theirsTimestamp: Date = Date()
    var resolutionRaw: String = ConflictResolution.unresolved.rawValue
    var detectedAt: Date = Date()
    var resolvedAt: Date?

    var field: ConflictField? {
        ConflictField(rawValue: fieldRaw)
    }

    var resolution: ConflictResolution {
        get { ConflictResolution(rawValue: resolutionRaw) ?? .unresolved }
        set { resolutionRaw = newValue.rawValue }
    }

    init(
        recordID: UUID,
        recordType: String,
        field: ConflictField,
        mineValue: String?,
        theirsValue: String?,
        mineAuthor: String?,
        theirsAuthor: String?,
        mineTimestamp: Date,
        theirsTimestamp: Date
    ) {
        self.id = UUID()
        self.recordID = recordID
        self.recordType = recordType
        self.fieldRaw = field.rawValue
        self.mineValue = mineValue
        self.theirsValue = theirsValue
        self.mineAuthorDeviceID = mineAuthor
        self.theirsAuthorDeviceID = theirsAuthor
        self.mineTimestamp = mineTimestamp
        self.theirsTimestamp = theirsTimestamp
        self.detectedAt = Date()
    }
}
