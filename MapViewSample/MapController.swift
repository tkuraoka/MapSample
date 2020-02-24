//
//  ViewController.swift
//  MapViewSample
//
//  Created by 倉岡隆志 on 2020/02/23.
//  Copyright © 2020 倉岡隆志. All rights reserved.
//

import UIKit
import MapKit

struct Map {
    enum Result<T> {
        case success(T)
        case failure(Error)
    }
    
    static func search(query: String, region: MKCoordinateRegion? = nil, completionHandler: @escaping (Result<[MKMapItem]>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = region {
            request.region = region
        }
        MKLocalSearch(request: request).start { (response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            completionHandler(.success(response?.mapItems ?? []))
        }
    }
}


class MapViewController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource {

    
    
    var shopNameArray:[String] = []
    var latArray:[Double] = []
    var longArray:[Double] = []
    var addressArray:[String] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopAddressLabel: UILabel!
    
    var myLocationManager:CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        myLocationManager = CLLocationManager()
        // 位置情報使用許可
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.delegate = self
        myLocationManager.startUpdatingLocation()
        // ２０メートルごとにこ位置情報更新
        myLocationManager.distanceFilter = 20.0
        

//        let coordinate = CLLocationCoordinate2DMake(35.6598051, 139.7036661) // 渋谷ヒカリエ
//        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0) // 1km * 1km
//
//        Map.search(query: "書店", region: region) { (result) in
//            switch result {
//            case .success(let mapItems):
//                for map in mapItems {
//                    print("name: \(map.name ?? "no name")")
//                    print("coordinate: \(map.placemark.coordinate.latitude) \(map.placemark.coordinate.latitude)")
//                    print("address \(map.placemark.address)")
//                }
//            case .failure(let error):
//                print("error \(error.localizedDescription)")
//            }
//        }

    }
    
    // 位置情報取得成功時
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("ここから")
        print(manager.location?.coordinate.latitude)
        print(manager.location?.coordinate.longitude)
        print("ここから")
        let lat = manager.location?.coordinate.latitude
        let long = manager.location?.coordinate.longitude
        let coordinate = CLLocationCoordinate2DMake(lat!, long!)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000.0,longitudinalMeters: 1000.0)
        
        Map.search(query: "書店", region: region) { (result) in
            switch result {
            case .success(let mapItems):
                for map in mapItems {
                    print("name: \(map.name ?? "no name")")
                    print("coodinate: \(map.placemark.coordinate.latitude) \(map.placemark.coordinate.latitude)")
                    print("address \(map.placemark.address)")
                    self.shopNameArray.append(map.name!)
                    self.latArray.append(map.placemark.coordinate.latitude)
                    self.longArray.append(map.placemark.coordinate.longitude)
                    self.addressArray.append(map.placemark.address)
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("error \(error.localizedDescription)")
            }
        }
        
    }
    // 位置情報取得に失敗したときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("sssss")
        print(shopNameArray.count)
        
        return shopNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell

        
       if let label1 = cell.viewWithTag(1) as? UILabel {
        label1.text = shopNameArray[indexPath.row]
        } else {
            print("no tag item")
        }
        if let label2 = cell.viewWithTag(2) as? UILabel {
            label2.text = addressArray[indexPath.row]
        } else {
            print("no tag item")
        }
//        label1.text = shopNameArray[indexPath.row]
//        label2.text = addressArray[indexPath.row]

        
        return cell
        
        
        
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}


extension MKPlacemark {
    var address : String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { ($0) }.joined(separator: "")
    }
}


