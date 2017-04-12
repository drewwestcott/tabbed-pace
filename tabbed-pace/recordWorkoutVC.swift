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
import AVFoundation

//MARK: - CLLocationManagerDelegate
class recordWorkoutVC: UIViewController, CLLocationManagerDelegate {
	
	//MARK: Outlets
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var paceLabel: UILabel!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var saveButton: UIButton!
	
	//MARK: Initialisation
	var start = CFAbsoluteTime()
	var workoutSeconds = 0
	var distance = 0.0
	var secDistance = 0.0
	var pace: Double = 0.0
	var averagePace: Double = 0.0
	
	let speech = AVSpeechSynthesizer()
	var feedbackUtterance = AVSpeechUtterance(string: "")
	var voiceToUse: AVSpeechSynthesisVoice?

	var annouceEvery = 30.0
	var count = 1.0
	
	lazy var locationManager: CLLocationManager = {
		
		var _locationManager = CLLocationManager()
		_locationManager.delegate = self
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest
		_locationManager.allowsBackgroundLocationUpdates = true
		_locationManager.activityType = .fitness
		
		return _locationManager
	}()

	let session = AVAudioSession.sharedInstance()

	lazy var locations = [CLLocation]()
	lazy var timer = Timer()
	lazy var unduck = Timer()
	
	let pedometer = CMPedometer()

	override func viewDidLoad() {
		super.viewDidLoad()
		pauseButton.isHidden = true
		saveButton.isHidden = true
		configureAudioSession()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		locationManager.requestAlwaysAuthorization()
		
		for voice in AVSpeechSynthesisVoice.speechVoices() {
			if #available(iOS 9.0, *) {
				if voice.name == "Samantha" {
					voiceToUse = voice
				}
			}
		}

	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//timer.invalidate()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func configureAudioSession(){
		do{
			try session.setCategory(AVAudioSessionCategoryPlayback, with: [.duckOthers])
		} catch {
			print(
				"Unable to configure audio session"
			)
			return
		}
		print("Audio Session Configured")
	}
	
	func deactivateAudio() {
		do {
		 try session.setActive(false)
		} catch {
			print("unable to deactivate")
		}
	}

	@IBAction func startButtonPressed() {
		
		workoutSeconds = 0
		distance = 0.0
		locations.removeAll()
		pauseButton.isHidden = false
		start = CFAbsoluteTimeGetCurrent()

		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
		startLocationUpdates()
		queryPedometer()
		
		
	}
	
	@IBAction func pauseButtonPressed() {
		
		timer.invalidate()
		pedometer.stopUpdates()
		locationManager.stopUpdatingLocation()
		
		print(locations.count)
		saveButton.isHidden = false
		pauseButton.isHidden = true
		deactivateAudio()
		
		
	}

	@IBAction func savePressed(_ sender: Any) {
		
		var workout = Workout(duration: Int(workoutSeconds), pace: pace, distance: distance)
		workoutSeconds = 0
		pace = 0.0
		distance = 0
		updateDisplay()
		print("Saved pressed")
		saveButton.isHidden = true
		
	}
	
	func updateDisplay(){
		
		let (hour,minute,seconds) = calculateHoursMinutesSeconds(seconds: workoutSeconds)
		timerLabel.text = "\(String(format: "%02d",hour)) : \(String(format: "%02d",minute)) : \(String(format: "%02d",seconds))"
		distanceLabel.text = String(format: "%\(0.2)f", distance/1000) + " meters"
		let kiloMeterPerHour = pace * 60 * 60 / 1000
		let paceText = String(format: "%\(0.2)f", kiloMeterPerHour) + " k/h"
		paceLabel.text =  paceText
		//print("\(String(format: "%02d",hour)) : \(String(format: "%02d",minute)) : \(String(format: "%02d",seconds))")
		
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
					self.secDistance += travelled
				}
			}
			
			self.locations.append(locations.last!)
			
		}
		
		workoutSeconds = Int(CFAbsoluteTimeGetCurrent() - start)
		print("Elapsed: \(workoutSeconds)")
		
		if workoutSeconds > Int(count * (annouceEvery - 1)) {
			vocalFeedback(feedbackTime: workoutSeconds)
			count += 1
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
	
	func vocalFeedback(feedbackTime: Int) {

		let (hours,minutes,seconds) = calculateHoursMinutesSeconds(seconds: feedbackTime)
		let elapsedTime = "Elapsed time, \(minutes) minutes and \(seconds) seconds. . ."
		let distanceTravelled = "Distance \(Int(distance)/1000) kilometers. . ."
		let secTravelled = "GPS Distance \(Int(secDistance))."
		
		let feedback = elapsedTime + distanceTravelled + secTravelled
		feedbackUtterance = AVSpeechUtterance(string: feedback)
		feedbackUtterance.rate = 0.5
		feedbackUtterance.voice = voiceToUse
		feedbackUtterance.volume = 0.4
		speech.speak(feedbackUtterance)
		unduck = Timer.scheduledTimer(timeInterval: 9, target: self, selector: #selector(deactivateAudio), userInfo: nil, repeats: false)

	}
	
	func calculateHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
		return(seconds / 3600, (seconds % 3600) / 60, (seconds % 60) % 60)
	}
}

