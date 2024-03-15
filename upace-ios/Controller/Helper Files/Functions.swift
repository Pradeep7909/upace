//
//  Functions.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import Foundation
import UIKit

func LOG(_ body: String = "", function: String = #function, line: Int = #line) {
    print("[\(function) : \(line)] \(body)")
}

func formatDate(_ dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    guard let date = dateFormatter.date(from: dateString) else {
        return nil // Return nil if the input date string is invalid
    }
    
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    return dateFormatter.string(from: date)
}

func formatTime(_ timeString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss" // Specify the input format
    if let date = dateFormatter.date(from: timeString) {
        dateFormatter.dateFormat = "h:mm a" // Specify the output format
        return dateFormatter.string(from: date)
    }
    return nil // Return nil if the input string is not in the expected format
}


func calculateTableViewHeight(for tableView: UITableView) -> CGFloat {
    var totalHeight: CGFloat = 0
    
    // Iterate through all sections
    for section in 0..<tableView.numberOfSections {
        // Iterate through all rows in the section
        for row in 0..<tableView.numberOfRows(inSection: section) {
            // Get the indexPath for the cell
            let indexPath = IndexPath(row: row, section: section)
            // Get the height of the cell
            let cellHeight = tableView.rectForRow(at: indexPath).height
            totalHeight += cellHeight
        }
        totalHeight += tableView.rectForHeader(inSection: section).height
        totalHeight += tableView.rectForFooter(inSection: section).height
    }
    
    return totalHeight
}



func parse(data : String) -> MediaPlacementResponse?{
    
    // Your mediaPlacement string
    let mediaPlacementString = """
    \(data)
"""
    
    var convertData : MediaPlacementResponse?
    
    // Unescape the string
    let unescapedString = mediaPlacementString
        .replacingOccurrences(of: #"\""#, with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
    
    // Convert the unescaped string to Data
    if let mediaPlacementData = unescapedString.data(using: .utf8) {
        do {
            // Decode the JSON data into a dictionary
            if let dictionary = try JSONSerialization.jsonObject(with: mediaPlacementData, options: []) as? [String: String] {
                // Access the values
                let audioHostUrl = dictionary["AudioHostUrl"] ?? ""
                let audioFallbackUrl = dictionary["AudioFallbackUrl"] ?? ""
                let signalingUrl = dictionary["SignalingUrl"] ?? ""
                let turnControlUrl = dictionary["TurnControlUrl"] ?? ""
                let screenDataUrl = dictionary["ScreenDataUrl"] ?? ""
                let screenViewingUrl = dictionary["ScreenViewingUrl"] ?? ""
                let screenSharingUrl = dictionary["ScreenSharingUrl"] ?? ""
                let eventIngestionUrl = dictionary["EventIngestionUrl"] ?? ""
                
                convertData = MediaPlacementResponse(audioHostUrl: audioHostUrl, audioFallbackUrl: audioFallbackUrl, signalingUrl: signalingUrl, turnControlUrl: turnControlUrl, screenDataUrl: screenDataUrl, screenViewingUrl: screenViewingUrl, screenSharingUrl: screenSharingUrl, eventIngestionUrl: eventIngestionUrl)
                
                
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    return convertData
    
}

