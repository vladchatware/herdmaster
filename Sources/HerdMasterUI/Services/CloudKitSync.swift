#if canImport(SwiftUI) && canImport(SwiftData)
import Foundation
import CoreData
import CloudKit
import SwiftData
import Combine

final class CloudKitSync: @unchecked Sendable {
    static let shared = CloudKitSync()

    private var container: NSPersistentCloudKitContainer?
    private var notificationTokens: [NSObjectProtocol] = []

    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var lastError: Error?
    @Published private(set) var pendingConflictCount: Int = 0

    private init() {}

    func configure(modelName: String = "HerdMaster") {
        let container = NSPersistentCloudKitContainer(name: modelName)

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store description found")
        }

        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Persistent store load failed: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        self.container = container
        observeSyncEvents()
    }

    private func observeSyncEvents() {
        let token = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: container,
            queue: .main
        ) { [weak self] notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event else { return }
            self?.handleSyncEvent(event)
        }
        notificationTokens.append(token)
    }

    private func handleSyncEvent(_ event: NSPersistentCloudKitContainer.Event) {
        if event.endDate == nil {
            isSyncing = true
            return
        }

        isSyncing = false

        if event.succeeded {
            lastSyncDate = event.endDate
            lastError = nil
        } else {
            lastError = event.error
        }
    }

    deinit {
        for token in notificationTokens {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

enum ConflictPolicy {
    case lastWriteWins
    case optimisticConcurrency
    case manualResolution
}

enum FieldStakes {
    case lowStakes
    case relational
    case breedingCritical

    var policy: ConflictPolicy {
        switch self {
        case .lowStakes: return .lastWriteWins
        case .relational: return .optimisticConcurrency
        case .breedingCritical: return .manualResolution
        }
    }
}

struct ConflictResolver {
    static let simultaneousWriteWindow: TimeInterval = 60

    static func resolve<T: Equatable>(
        mine: T,
        theirs: T,
        stakes: FieldStakes,
        mineTimestamp: Date,
        theirsTimestamp: Date,
        onManualNeeded: (T, T) -> T
    ) -> T {
        switch stakes.policy {
        case .lastWriteWins:
            return mineTimestamp >= theirsTimestamp ? mine : theirs

        case .optimisticConcurrency:
            let gap = abs(mineTimestamp.timeIntervalSince(theirsTimestamp))
            if gap < simultaneousWriteWindow {
                return onManualNeeded(mine, theirs)
            }
            return mineTimestamp >= theirsTimestamp ? mine : theirs

        case .manualResolution:
            return onManualNeeded(mine, theirs)
        }
    }
}

enum UniqueEnforcement {
    static func isEarNumberTaken(
        _ earNumber: String,
        excluding excludedID: UUID? = nil,
        in context: ModelContext
    ) throws -> Bool {
        let predicate = #Predicate<Animal> { animal in
            animal.earNumber == earNumber
        }
        let descriptor = FetchDescriptor<Animal>(predicate: predicate)
        let matches = try context.fetch(descriptor)

        if let excludedID = excludedID {
            return matches.contains { $0.id != excludedID }
        }
        return !matches.isEmpty
    }
}
#endif
