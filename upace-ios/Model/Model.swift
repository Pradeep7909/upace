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
