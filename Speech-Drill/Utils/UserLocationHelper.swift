//
//  UserLocationHelper.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 11/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import CoreLocation

func storeLocationInFirebase(locationManager: CLLocationManager) {
    
    let uuid = UUID().uuidString
    var isoCode = "UNK"

    if  CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied
            || !CLLocationManager.locationServicesEnabled() {
        
        saveUserLocation(isoCode: isoCode, uuid: uuid)
        print("Saving status for: ", uuid, " as", isoCode)
        
    } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse && CLLocationManager.locationServicesEnabled()  {
        

        let geoCoder = CLGeocoder()
        
        guard let currentLocation = locationManager.location else {
            saveUserLocation(isoCode: isoCode, uuid: uuid)
            return
        }
        
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard let currentLocPlacemark = placemarks?.first else {
                saveUserLocation(isoCode: isoCode, uuid: uuid)
                return
            }
            print(currentLocPlacemark.country ?? "No country found")
            print(currentLocPlacemark.isoCountryCode ?? "No country code found")
            isoCode = currentLocPlacemark.isoCountryCode ?? isoCode
            
            print("Saving status for: ", uuid, " as", isoCode)
            saveUserLocation(isoCode: isoCode, uuid: uuid)
            //SAVE ISO CODE +1 TO FIREBASE
            
        }
    }
}

func saveUserLocation(isoCode: String, uuid: String) {
    userLocationReference.child(uuid).setValue(isoCode)
    userLocationReference.child(uuid).onDisconnectSetValue(nil)
    let defaults = UserDefaults.standard
    defaults.set(isoCode, forKey: userLocationCodeKey)
    defaults.set(flag(from: isoCode), forKey: userLocationEmojiKey)
}

func flag(from country:String) -> String {
    
    if country == "UNK" {
        return "🏴‍☠️"
    } else {
        let base : UInt32 = 127397
        var s = ""
        for v in country.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}
