//
//  image.swift
//  VirtualTourist
//
//  Created by Owais Gaffas on 05/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

let cache = NSCache<NSString, AnyObject> ()

class Image : UIImageView {
    
    var URLIamge: URL!
    
    func setPhoto(_ newPhoto: Photo) {
        if photo != nil {
            return
        }
        photo = newPhoto
    }
    
    private var photo: Photo! {
        didSet {
            if let image = photo.getPhoto() {
                hideIndicator()
                self.image = image
                return
            }
            guard let url = photo.imageURL else {
                return
            }
            
            loadImage(with: url)
        }
    }
    func loadImage(with url: URL){
        URLIamge = url
        image = nil
        showIndicator()
        
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
            hideIndicator()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                //network
                print(error.localizedDescription)
                return
            }
            
            guard let downloadPhoto = UIImage(data: data!) else {
                return
            }
            cache.setObject(downloadPhoto, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = downloadPhoto
                self.photo.setPhoto(image: downloadPhoto)
                do {
                    try self.photo.managedObjectContext?.save()
                } catch {
                    print(error.localizedDescription)
                }
                self.hideIndicator()
            }
            }
            .resume()
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    func showIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
}
