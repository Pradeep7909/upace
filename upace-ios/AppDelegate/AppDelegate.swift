//
//  AppDelegate.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import UIKit
import AmazonChimeSDK
import AmazonChimeSDKMedia
import AWSCore
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let credentials = AWSStaticCredentialsProvider(accessKey: "AKIAUATGMLVC57FVIZNU", secretKey: "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")
        let configuration = AWSServiceConfiguration(region: AWSRegionType.APSouth1 , credentialsProvider: credentials)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        FirebaseApp.configure()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

