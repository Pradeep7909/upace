//
//  Singleton.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import Foundation
import UIKit

class Singleton {
    
    static let shared = Singleton()
    
    private init() {
        print("Singletone user is setted because init is called")
        currentUser = loadUser()
        currentTheme = loadTheme()
        setAppTheme()
    }
    
    private(set) var currentUser: UserDetail? {
        didSet {
            print("user setted")
            saveUser()
        }
    }
    
    var currentTheme : String? {
        didSet {
            setAppTheme()
            saveTheme()
        }
    }
    var selectedEvent : Event?
    var currentJoinMeeting : MeetingJoinResponse?
    var savedBoothList : BoothResponse?
    
    private let userDefaults = UserDefaults.standard
    
    func setUser(_ user: UserDetail) {
        currentUser = user
    }
    
    func getUser() -> UserDetail? {
        return currentUser ?? loadUser()
    }
    
    func handleLogout() {
        currentUser = nil
        userDefaults.removeObject(forKey: UD_USER_DETAIL)
        // Remove observer for showMeetingViewController notification
        FirebaseManager.shared.removeObservers()
        NotificationCenter.default.removeObserver(self, name: .showMeetingViewController, object: nil)
            
    }
    
    private func saveUser() {
        if let user = currentUser, let encodedData = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedData, forKey: UD_USER_DETAIL)
        }
    }
    
    private func loadUser() -> UserDetail? {
        if let savedData = userDefaults.data(forKey: UD_USER_DETAIL),
           let user = try? JSONDecoder().decode(UserDetail.self, from: savedData) {
            return user
        }
        return nil
    }
    
    private func loadTheme() -> String {
        if let theme =  userDefaults.string(forKey: UD_APP_THEME){
            return theme
        }
        return "light"
    }
    
    private func saveTheme() {
        userDefaults.set(currentTheme, forKey: UD_APP_THEME)
    }
    
    func setAppTheme() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.overrideUserInterfaceStyle = currentTheme == "dark" ? .dark : .light
        }
    }
}
