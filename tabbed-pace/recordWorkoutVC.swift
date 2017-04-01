//
//  FirstViewController.swift
//  tabbed-pace
//
//  Created by Drew Westcott on 22/03/2017.
//  Copyright © 2017 Drew Westcott. All rights reserved.
//
//	Running on Treadmill by Gan Khoon Lay from the Noun Project

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
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var saveButton: UIButton!
	
	//MARK: Initialisation
	var seconds = 0.0
	var distance = 0.0
	var pace: Double = 0.0
	var averagePace: Double = 0.0
	
	lazy var locationManager: CLLocationManager = {
		
		var _locationManager = CLLocationManager()
		_locationManager.delegate = self
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest
		_locationManager.activityType = .fitness
		
		return _locationManager
	}()
	
	lazy var locations = [CLLocation]()
	lazy var timer = Timer()
	lazy var feedback = Timer()
	
	let pedometer = CMPedometer()

	override func viewDidLoad() {
		super.viewDidLoad()
		pauseButton.isHidden = true
		saveButton.isHidden = true
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
		pauseButton.isHidden = false

		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond), userInfo: nil, repeats: true)
		feedback = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(vocalFeedback(time:pace:)), userInfo: nil, repeats: true)
		//startLocationUpdates()
		queryPedometer()
		
		
	}
	
	@IBAction func pauseButtonPressed() {
		
		timer.invalidate()
		pedometer.stopUpdates()
		//locationManager.stopUpdatingLocation()
		var workout = Workout(duration: Int(seconds), pace: pace, distance: distance)
		
		print(locations.count)
		saveButton.isHidden = false
		pauseButton.isHidden = true
		
		
	}

	@IBAction func savePressed(_ sender: Any) {
		
		print("Saved pressed")
		saveButton.isHidden = true
		
	}
	
	func eachSecond(timer: Timer){
		
		var displaySeconds = 0.0
		seconds += 1
		pauseButton.isHidden = false
		
		let minute = seconds / 60.0
		if seconds > 59 {
			let roundMinute = Int(minute) * 60
			displaySeconds = seconds - (Double(roundMinute))
		} else {
			displaySeconds = seconds
		}
		let hour = seconds / (60.0 * 60.0)
		timerLabel.text = "\(String(format: "%02d",Int(hour))) : \(String(format: "%02d",Int(minute))) : \(String(format: "%02d",Int(displaySeconds)))"
		distanceLabel.text = String(format: "%\(0.2)f", distance/1000) + " meters"
		let kiloMeterPerHour = pace * 60 * 60 / 1000
		let paceText = String(format: "%\(0.2)f", kiloMeterPerHour) + " k/h"
		paceLabel.text =  paceText
		
	}
	
	func startLocationUpdates() {
	
		locationManager.startUpdatingLocation()
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		for location in locations {
			print("Locations:\(locations.count)")
			
			if self.locations.count > 0 {
				let travelled = location.distance(from: self.locations.last!)
				print(travelled)
				if travelled > 1 {
					self.distance += travelled
				}
			}
			
			self.locations.append(locations.last!)
		}
		
	}
	
	func queryPedometer() {
	
		pedometer.startUpdates(from: Date()) { (data, error) in
		
		guard let pedometerData = data else {
		return
		}
		
		guard CMPedometer.isPaceAvailable() else {
		print("Pace unavailable")
		return
		}
		
			if let currentPace = pedometerData.currentPace as? Double {
				self.pace = (Double(pedometerData.currentPace!))
			} else {
				self.pace = 0.0
			}
		print("Pace: \(String(describing: pedometerData.currentPace))")
		print("Pace: \(self.pace)")
		
		guard CMPedometer.isDistanceAvailable() else {
		print("Distance is unavailable")
		return
		}
		
		self.distance = pedometerData.distance as! Double
		
		
		print("Distance: \(self.distance)")
		}

	
	}
	
	func vocalFeedback(time: Double, pace: Double) {
		
	}
}

