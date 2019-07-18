//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Owais Gaffas on 01/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit


class PhotosViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var newPhoto: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textLabel: UILabel!
    
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var pageNumber = 1
    var isDeletingEverything = false
    
    var context: NSManagedObjectContext {
        return DataController.instance.viewContext
    }
    
    var doWeHavePhotos: Bool {
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        setupFetchedResultsController()
    }
    override func viewDidAppear(_ animated: Bool) {
        if CheckInternetConnection.Connection() == false {
            alerts(errorMessage: "Internet not working!!!")
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: false)
        ]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if !doWeHavePhotos {
                buttomButtonTapped(self)
                collectionView.reloadData()
            }
            updateUI(processing: false)
            
        } catch {
            fatalError("The fetch could not be performd: \(error.localizedDescription)")
        }
    }
    
    @IBAction func buttomButtonTapped(_ sender: Any) {
        updateUI(processing: true)
        
        if doWeHavePhotos {
            isDeletingEverything = true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            isDeletingEverything = false
        }
        
        FlickerAPI.getPhotos(with: pin.cord, pageNum: pageNumber) { (urls, error, errorMessage) in
            DispatchQueue.main.async {
                
                self.updateUI(processing: false)
                
                guard (error == nil) && (errorMessage == nil) else {
                    //network
                    self.alerts(errorMessage: error?.localizedDescription ?? errorMessage)
                    return
                }
                
                guard let urls = urls, !urls.isEmpty else {
                    self.textLabel.isHidden = false
                    return
                }
                
                for url in urls {
                    let photo = Photo(context: self.context)
                    photo.imageURL = url
                    photo.pin = self.pin
                    photo.createdDate = Date()
                    do {
                        try self.context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                
            }
        }
        pageNumber += 1
    }
    
    func updateUI(processing: Bool) {
        collectionView.isUserInteractionEnabled = !processing
        if processing {
            newPhoto.isEnabled = false
            activityIndicator.startAnimating()
            
        } else {
            activityIndicator.stopAnimating()
            newPhoto.isEnabled = true
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.setPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

            if let indexPath = indexPath, type == .delete && !isDeletingEverything {
                collectionView.deleteItems(at: [indexPath])
                return
            }
    
            if let indexPath = indexPath, type == .insert {
                collectionView.insertItems(at: [indexPath])
                return
            }

            if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
                collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
                return
            }

            if type != .update {
                collectionView.reloadData()
            }
        }
    
}


extension PhotosViewController {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.cord
        mapView.addAnnotation(annotation)
        mapView.region = MKCoordinateRegion(center: pin.cord, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
    
}
