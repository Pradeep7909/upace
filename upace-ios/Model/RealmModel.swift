//
//  RealmModel.swift
//  upace-ios
//
//  Created by Qualwebs on 03/04/24.
//

import Foundation
import RealmSwift



class RealmEventResponse: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var total: Int = 0
    @objc dynamic var totalPage: Int = 0
    
    let data = List<RealmEvent>()
    
    override static func primaryKey() -> String? {
        return "id" // Specify the primary key
    }
}

class RealmEvent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var tag_line: String? = nil
    @objc dynamic var event_date: String = ""
    @objc dynamic var event_start_time: String = ""
    @objc dynamic var event_end_time: String = ""
}


class RealmBoothResponse: Object {
    var data = List<RealmBoothData>()
}


class RealmBoothData: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var event_id: String = ""
    @objc dynamic var university_external_id: String?
    @objc dynamic var status: String?
    @objc dynamic var token_number: Int = 0
    @objc dynamic var counsellor_id: String?
    @objc dynamic var queue_id: String?
    @objc dynamic var vFairEvent: RealmEvent?
    @objc dynamic var University: RealmUniversity?

    override static func primaryKey() -> String? {
        return "id"
    }
}


class RealmUniversity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var logo: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var country: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var bannerImage: String = ""
    @objc dynamic var fees: String = ""
    @objc dynamic var bestFor: String = ""
    @objc dynamic var institutionType: String = ""
    

    override static func primaryKey() -> String? {
        return "id"
    }
}
