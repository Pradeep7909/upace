//
//  Model.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import Foundation

struct ErrorResponse: Codable{
    var message: String?
    var url: String?
}

struct LoginResponse: Codable {
    let status: Int?
    let data: LoginData?
    let message: String?
}

struct LoginData: Codable {
    let user: UserDetail?
    let token: String?
    let upaceToken: String?
}

struct UserDetail: Codable {
    let id: String
    let name: String?
    let email: String?
    let mobile_phone: String?
    let profile_image: String?
}

struct EventResponse: Codable {
    let data: [Event]
    let total: Int
    let totalPage: Int?
}

struct Event: Codable {
    let id: String
    let title: String
    let type: String
    let tag_line: String?
    let event_date: String
    let event_start_time: String
    let event_end_time: String
}

struct SubscriptionResponse: Codable {
    let status: String?
}

struct MenuCell : Codable{
    let imageName: String
    let title: String
}

struct BoothResponse: Codable {
    let data: [BoothData]
}

struct BoothData: Codable {
    let id: String
    let event_id: String
    let university_external_id: String?
    let vFairEvent: Event
    let University: University
}


struct University: Codable {
    let id: String?
    let logo: String?
    let name: String?
    let country: String?
    let city: String?
    let bannerImage: String?
    let fees: String?
    let bestFor: String?
    let institutionType: String?
}

struct FAQ : Codable{
    let question : String
    let answer : String
}



struct JoinInfoResponse: Codable {
    let status: Int?
    let data: JoinInfoData?
    let message: String?
    let action: String?
    
}

struct JoinInfoData: Codable {
    let JoinInfo: JoinInfo?
}

struct JoinInfo: Codable {
    let Meeting: MeetingData?
    let Attendee: AttendeeData?
}

struct MeetingData: Codable {
    let MeetingId: String
    let ExternalMeetingId: String
    let MediaPlacement: String
    let MediaRegion: String
}

struct AttendeeData: Codable {
    let ExternalUserId: String
    let AttendeeId: String
    let JoinToken: String
}

struct MediaPlacementResponse: Codable {
    let audioHostUrl: String
    let audioFallbackUrl: String
    let signalingUrl: String
    let turnControlUrl: String
    let screenDataUrl: String
    let screenViewingUrl: String
    let screenSharingUrl: String
    let eventIngestionUrl: String
}

struct QueueResponse: Codable {
    let status: Int?
    let message: String?
    let data: QueueData?
}

struct QueueData: Codable{
    let id: String?
    let user_id: String?
    let university_id: String?
    let event_id: String?
    let counsellor_id: String?
    let token_number: Int?
    let status: String?
}
