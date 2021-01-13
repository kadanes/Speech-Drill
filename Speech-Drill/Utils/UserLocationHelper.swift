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
    
    if  CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied
            || !CLLocationManager.locationServicesEnabled() {
        
        let isoCode = "UNK"
            
        userLocationReference.child(uuid).setValue(isoCode)
        userLocationReference.onDisconnectSetValue(nil)
        
        print("Saving status for: ", uuid, " as", isoCode)
        
    } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse && CLLocationManager.locationServicesEnabled()  {
        

        let geoCoder = CLGeocoder()
        
        guard let currentLocation = locationManager.location else { return }
        
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard let currentLocPlacemark = placemarks?.first else { return }
            print(currentLocPlacemark.country ?? "No country found")
            print(currentLocPlacemark.isoCountryCode ?? "No country code found")
            guard let isoCode = currentLocPlacemark.isoCountryCode else { return }
            
            print("Saving status for: ", uuid, " as", isoCode)
            
            //SAVE ISO CODE +1 TO FIREBASE
            userLocationReference.child(uuid).setValue(isoCode)
            userLocationReference.onDisconnectSetValue(nil)
        }
    }
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
