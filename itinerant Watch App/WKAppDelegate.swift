//
//  WKAppDelegate.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 26/01/2023.
//

import SwiftUI
import WatchConnectivity



class WKAppDelegate: NSObject, WKApplicationDelegate, ObservableObject     {
    
    func applicationDidFinishLaunching() {
        
        initiateWatchConnectivity()
    }
    
    
}


extension WKAppDelegate: WCSessionDelegate {
    
    func initiateWatchConnectivity() {
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            debugPrint("WCSession.isSupported false")
        }
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("WCSession activationDidCompleteWith", activationState.rawValue.description, error?.localizedDescription ?? "No error")
        
    }
    
    // MARK: - Messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint("didReceiveMessage")

        if let notificationText = message[kMessageItineraryData] as? Data {
            debugPrint(notificationText)
        }
    }
    
    
    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
            debugPrint("WCSession.activationState not activated", WCSession.default.activationState)
            return
        }
        guard WCSession.default.isCompanionAppInstalled else {
            debugPrint("isCompanionAppInstalled false")
            return
        }
        
        debugPrint("WK WCSession.default.sendMessage")
        WCSession.default.sendMessage([kMessageKey : message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
    
    
}
