//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Galina evdokimova on 18.05.2025.
//

import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidTrackerId
    case decodingErrorInvalidDate
    case decodingErrorInvalidFetchTracker
    case invalidDeleteTrackerRecord
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func recordStore()
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.trackerRecord(from: $0) })
        else { return [] }
        return trackers
    }
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerId, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetchedResultsController.delegate = self
    }
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord?) throws {
        guard let deleteTrackerRecord = try self.fetchTrackerRecord(with: trackerRecord) else {
            throw TrackerRecordStoreError.invalidDeleteTrackerRecord
        }
        context.delete(deleteTrackerRecord)
        try context.save()
    }
    
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData,
                                     with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.trackerId = trackerRecord.trackerId
        trackerRecordCoreData.date = trackerRecord.date
    }
    
    func fetchTrackerRecord(with trackerRecord: TrackerRecord?) throws -> TrackerRecordCoreData? {
        guard let trackerRecord = trackerRecord else {
            throw TrackerRecordStoreError.decodingErrorInvalidFetchTracker
        }
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@",
            trackerRecord.trackerId as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
    private func trackerRecord(
        from trackersRecordCoreData: TrackerRecordCoreData
    ) throws -> TrackerRecord {
        guard let trackerId = trackersRecordCoreData.trackerId else {
            throw TrackerRecordStoreError.decodingErrorInvalidTrackerId
        }
        
        guard let date = trackersRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidDate
        }
        
        return TrackerRecord(
            trackerId: trackerId,
            date: date)
    }
}
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.recordStore()
    }
}

