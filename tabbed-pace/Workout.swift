//
//  Workout.swift
//  tabbed-pace
//
//  Created by Drew Westcott on 30/03/2017.
//  Copyright © 2017 Drew Westcott. All rights reserved.
//

import Foundation

class Workout {
	
	var _distance: Double!
	var _pace: Double!
	var _duration: Int!
	
	var distance: Double {
		
		return _distance
		
	}
	
	var pace: Double {
		
		return _pace
		
	}
	
	var duration: Int {
		
		return _duration
		
	}
	
	init(duration: Int, pace: Double, distance: Double = 0.0) {
		
		_duration = duration
		_pace = pace
		_distance = distance
		
	}
}
