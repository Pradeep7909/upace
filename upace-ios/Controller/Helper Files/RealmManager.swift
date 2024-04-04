//
//  RealmManager.swift
//  upace-ios
//
//  Created by Qualwebs on 04/04/24.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    private init() {
        // Specify Realm configuration with migration block
        let config = Realm.Configuration(
            schemaVersion: 1, // Set the new schema version
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion != 1 {
                    // Delete all objects of the old schema version
                    migration.deleteData(forType: RealmEventResponse.className())
                    migration.deleteData(forType: RealmBoothResponse.className())
                    // Perform similar deletion for other objects if needed
                }
            }
        )
        
        do {
            // Apply the Realm configuration
            realm = try Realm(configuration: config)
        } catch {
            fatalError("Error initializing Realm: \(error.localizedDescription)")
        }
    }
    
    lazy var realm: Realm = {
        do {
            let realm = try Realm()
            return realm
        } catch {
            fatalError("Error initializing Realm: \(error.localizedDescription)")
        }
    }()
    
    
    
    //MARK: Home screen event details
    func fetchCachedEvent(completion: @escaping (RealmEventResponse?) -> Void) {
        completion(realm.objects(RealmEventResponse.self).first)
    }
    
    func compareEventTime(cachedResponse : RealmEventResponse) -> Bool {
        
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust date format to include milliseconds
        
        // Extract the first event from the cached response
        if let firstEvent = cachedResponse.data.first {
            var endTime = firstEvent.event_date
            
            if let range = endTime.range(of: "T") {
                let startIndex = range.upperBound
                if let endIndex = endTime.firstIndex(of: ".") {
                    endTime.replaceSubrange(startIndex..<endIndex, with: firstEvent.event_end_time)
                }
            }
            
            // Convert the corrected combined date-time string to a Date object for comparison
            if let combinedDateTime = dateFormatter.date(from: endTime) {
                return combinedDateTime > currentTime
            } else {
                print("Error: Failed to parse corrected combined date-time string")
            }
        }
        return false
    }
    
    func saveEventData(response: EventResponse, completion: @escaping (RealmEventResponse) -> Void) {
        
        let realmResponse = RealmEventResponse()
        realmResponse.total = response.total
        realmResponse.totalPage = response.totalPage ?? 0
        
        let realmEvents = response.data.map { event -> RealmEvent in
            let realmEvent = RealmEvent()
            realmEvent.id = event.id
            realmEvent.title = event.title
            realmEvent.type = event.type
            realmEvent.tag_line = event.tag_line
            realmEvent.event_date = event.event_date
            realmEvent.event_start_time = event.event_start_time
            realmEvent.event_end_time = event.event_end_time
            return realmEvent
        }
        
        try! realm.write {
            realm.delete(realm.objects(RealmEventResponse.self))
            realm.delete(realm.objects(RealmEvent.self))
            
            realmResponse.data.append(objectsIn: realmEvents)
            realm.add(realmResponse, update: .modified)
        }
        
        // Call completion handler with updated realmResponse
        completion(realmResponse)
    }
    
    
    
    //MARK: Booth Screen event Details
    
    func fetchCachedBooth(completion: @escaping (RealmBoothResponse?) -> Void) {
        completion(realm.objects(RealmBoothResponse.self).first)
    }
    
    func saveBoothData(_ boothResponse: BoothResponse, completion: @escaping (RealmBoothResponse) -> Void) {
        let realm = try! Realm()
        let data = convertBoothResponse(boothResponse)
        try! realm.write {
            realm.delete(realm.objects(RealmBoothResponse.self))
            realm.delete(realm.objects(RealmBoothData.self))
            realm.delete(realm.objects(RealmUniversity.self))
            realm.add(data)
        }
        completion(data)
    }
    
    private func convertBoothResponse(_ boothResponse: BoothResponse) -> RealmBoothResponse {
        let realmBoothResponse = RealmBoothResponse()
        let realmBoothDataList = List<RealmBoothData>()
        
        for boothData in boothResponse.data {
                // Create new object
                let realmBoothData = RealmBoothData()
                realmBoothData.id = boothData.id
                realmBoothData.event_id = boothData.event_id
                realmBoothData.university_external_id = boothData.university_external_id
                realmBoothData.status = boothData.status
                realmBoothData.token_number = boothData.token_number ?? 0
                realmBoothData.counsellor_id = boothData.counsellor_id
                realmBoothData.queue_id = boothData.queue_id
                realmBoothData.University = convertUniversityToRealmObject(boothData.University)
                realmBoothDataList.append(realmBoothData)
        }
        
        realmBoothResponse.data = realmBoothDataList
        return realmBoothResponse
    }
    
    //no use beacuse it is already saved at home screen.
    
//    private func convertEventToRealmObject(_ event: Event) -> RealmEvent {
//        // Implement conversion logic if needed
//        // Example:
//        let realmEvent = RealmEvent()
//        realmEvent.id = event.id
//        realmEvent.title = event.title
//        // Set other properties...
//        return realmEvent
//    }
    
    
    private func convertUniversityToRealmObject(_ university: University) -> RealmUniversity {
        // Implement conversion logic if needed
        // Example:
        let realmUniversity = RealmUniversity()
        realmUniversity.id = university.id ?? ""
        realmUniversity.name = university.name ?? ""
        realmUniversity.country = university.country ?? ""
        realmUniversity.city = university.city ?? ""
        realmUniversity.bannerImage = university.bannerImage ?? ""
        realmUniversity.fees = university.fees ?? ""
        realmUniversity.bestFor = university.bestFor ?? ""
        realmUniversity.institutionType = university.institutionType ?? ""
        
        // Set other properties...
        return realmUniversity
    }
    
}
