//
//  FirstViewController.swift
//  tabbed-pace
//
//  Created by Drew Westcott on 22/03/2017.
//  Copyright © 2017 Drew Westcott. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import HealthKit

//MARK: - CLLocationManagerDelegate
class recordWorkoutVC: UIViewController, CLLocationManagerDelegate {
	
	//MARK: Outlets
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var paceLabel: UILabel!
	
	//MARK: Initialisation
	var seconds = 0.0
	var distance = 0.0
	var pace: Double = 0.0
	
	lazy var locationManager: CLLocationManager = {
		
		var _locationManager = CLLocationManager()
		_locationManager.delegate = self
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest
		_locationManager.activityType = .fitness
		
		return _locationManager
	}()
	
	lazy var locations = [CLLocation]()
	lazy var timer = Timer()
	
	let pedometer = CMPedometer()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		locationManager.requestAlwaysAuthorization()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		timer.invalidate()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func startButtonPressed() {
		
		seconds = 0.0
		distance = 0.0
		locations.removeAll()
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond), userInfo: nil, repeats: true)
		
		pedometer.startUpdates(from: Date()) { (data, error) in
			
			guard let pedometerData = data else {
				return
			}
			
			guard CMPedometer.isPaceAvailable() else {
				return
			}
			
			self.pace = pedometerData.currentPace as! Double
			let distance = pedometerData.distance
		
		
			print("Pace: \(self.pace)  Distance: \(distance)")
		}
		
		
		
	}
	
	@IBAction func pauseButtonPressed() {
		
		timer.invalidate()
		pedometer.stopUpdates()
		locationManager.stopUpdatingLocation()
		print(locations.count)
		
	}

	func eachSecond(timer: Timer){
		
		var displaySeconds = 0.0
		seconds += 1
		
		let minute = seconds / 60.0
		if seconds > 59 {
			let roundMinute = Int(minute) * 60
			displaySeconds = seconds - (Double(roundMinute))
		} else {
			displaySeconds = seconds
		}
		let secondsQuality = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
		timerLabel.text = "0 : \(Int(minute)) : \(displaySeconds)"
		let distanceQuality = HKQuantity(unit: HKUnit.mile(), doubleValue: distance)
		distanceLabel.text = "\(distanceQuality)"
		let paceText = String(format: "%\(0.2)f", pace) + " pace"
		paceLabel.text =  paceText
		
	}
	
	func startLocationUpdates() {
	
		locationManager.startUpdatingLocation()
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		for location in locations {
			
			if self.locations.count > 0 {
				distance += location.distance(from: self.locations.last!)
			}
			
			self.locations.append(location)
		}
		
	}
}

