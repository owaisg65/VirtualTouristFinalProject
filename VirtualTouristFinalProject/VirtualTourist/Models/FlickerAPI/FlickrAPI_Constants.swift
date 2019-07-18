//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Owais Gaffas on 01/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct FlickrAPI_Constants {
    
    struct constent {
        
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
    }
    
    struct keys {
        static let apikey = "api_key"
        static let method = "method"
        static let BBox = "bbox"
        static let page = "page"
        static let perPage = "per_page"
        static let format = "format"
        static let noJson = "nojsoncallback"
        static let safe = "safe_search"
        static let Text = "text"
        static let Extras = "extras"
    }
    struct value {
        static let apivalue = "d94b589a0fd39576c6d9cf5cd4914d79"
        static let serach = "flickr.photos.search"
        static let perPageValue = 30
        static let formatValue = "json"
        static let noJsonValue = "1"
        static let Url = "url_m"
        static let safeSearch = "1"
        static let GalleryPhotos = "flickr.galleries.getPhotos"
        
    }
    
}

