//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Owais Gaffas on 01/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit


struct FlickerAPI {
    static func getPhotos(with cordinate: CLLocationCoordinate2D, pageNum : Int, completion: @escaping ([URL]?,Error?, String?)->()) {
        let method = [
            
            FlickrAPI_Constants.keys.method : FlickrAPI_Constants.value.serach,
            FlickrAPI_Constants.keys.apikey : FlickrAPI_Constants.value.apivalue,
            
            FlickrAPI_Constants.keys.BBox : bboxString(for: cordinate),
            
            FlickrAPI_Constants.keys.safe : FlickrAPI_Constants.value.safeSearch,
            FlickrAPI_Constants.keys.Extras : FlickrAPI_Constants.value.Url,
            FlickrAPI_Constants.keys.format : FlickrAPI_Constants.value.formatValue,
            FlickrAPI_Constants.keys.noJson : FlickrAPI_Constants.value.noJsonValue,
            
            FlickrAPI_Constants.keys.page : pageNum,
            
            FlickrAPI_Constants.keys.perPage : FlickrAPI_Constants.value.perPageValue,
            ] as [String : Any]
        
        let urlRequest = URLRequest(url: getURL(from: method))
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                completion(nil,error,nil)
                return
            }
            guard let data = data else {
                completion (nil,nil,"No Data!")
                return
                
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                completion(nil,nil,"Error Performing Your request ")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                completion(nil,nil,"Error Parsing Json")
                return
            }
            
            guard let status = result["stat"] as? String, status == "ok" else {
                completion(nil,nil,"Error in Flicker API")
                return
            }
            guard let photosDic = result["photos"] as? [String:Any] else {
                completion(nil,nil, "No Photos Found")
                return
            }
            
            guard let photosArray = photosDic["photo"] as? [[String:Any]] else {
                completion(nil,nil,"Key Photo Not Found")
                return
            }
            
            let photoUrls = photosArray.compactMap { photosDic -> URL? in
            guard let url = photosDic["url_m"] as? String else {
                return nil}
                return URL(string: url) }
            completion(photoUrls,nil,nil)
        }
            task.resume()
    }
    
    static func getURL(from method: [String : Any]) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = FlickrAPI_Constants.constent.scheme
        urlComponents.host = FlickrAPI_Constants.constent.host
        urlComponents.path = FlickrAPI_Constants.constent.path
        
        urlComponents.queryItems = [URLQueryItem]()
        
        for (key, value) in method {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems!.append(queryItem)
        }
        
        return urlComponents.url!
    }
    
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let lowerLon = max(longitude - 0.2, -180)
        let lowerLat = max(latitude - 0.2, -90)
        let higherLon = min(longitude + 0.2, 180)
        let higherLat = min(latitude + 0.2, 90)
        
        return "\(lowerLon),\(lowerLat),\(higherLon),\(higherLat)"
    }
}
