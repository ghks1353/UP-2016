//
//  AnalyticsManager.swift
//  UP
//
//  Created by 문화창조아카데미12 on 2016. 5. 1..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import Google;

class AnalyticsManager {
	
	// Screen name
	static let T_SCREEN_MAIN:String = "Screen-Main";
	static let T_SCREEN_SETTINGS:String = "Screen-Settings";
	static let T_SCREEN_ALARMLIST:String = "Screen-AlarmList";
	static let T_SCREEN_ALARMADD:String = "Screen-AlarmAdd";
	static let T_SCREEN_STATS:String = "Screen-Statistics";
	static let T_SCREEN_CHARACTERINFO:String = "Screen-CharacterInformation";
	static let T_SCREEN_GAME_JUMPUP:String = "Screen-Game-JumpUP";
	static let T_SCREEN_PLAYGAME:String = "Screen-GameSelect";
	static let T_SCREEN_RESULT:String = "Screen-Result";
	static let T_SCREEN_PLAYGAME_READY:String = "Screen-GameSelect-Ready";
	
	// Event category
	static let E_CATEGORY_GAMEDATA:String = "Event-Game";
	
	// Event action
	static let E_ACTION_GAME_JUMPUP:String = "JumpUP";
	
	// Event Label (With game)
	static let E_LABEL_JUMPUP_PLAYTIME:String = "JumpUP-PlayTime";
	
	// Event label
	//static let E_LABEL_START:String = "Start";
	
	
	//////////////
	
	//Tracking store array
	static var trackingArray:Array<String> = [];
	
	//init google analytics
	static func initGoogleAnalytics() {
		// Configure tracker from GoogleService-Info.plist.
		/*var configureError:NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(configureError)")
		
		// Optional: configure GAI options.
		let gai = GAI.sharedInstance()
		gai.trackUncaughtExceptions = true  // report uncaught exceptions
		//gai.logger.logLevel = GAILogLevel.Warning;  // remove before app release
		*/
	}
	
	/// Tracking usage by google analytics
	static func trackScreen( _ screenName:String, registerToArray:Bool = true ) {
		/*let tracker = GAI.sharedInstance().defaultTracker; tracker.allowIDFACollection = true;
		tracker.set(kGAIScreenName, value: screenName);
		let builder = GAIDictionaryBuilder.createScreenView();
		tracker.send(builder.build() as [AnyHashable: Any]);
		
		print("Tracking", screenName);*/
		if (registerToArray) {
			trackingArray += [screenName];
		}
	} //end func
	static func untrackScreen() -> Bool {
		if (trackingArray.count > 1) { //적어도 두개여야함
			print("Untracking screen");
			trackingArray.removeLast();
			//trackScreen( trackingArray[ trackingArray.count - 1], registerToArray: false);
			return true;
		}
		print("Untracking failed");
		return false; // untrack failed
	}
	
	///// Make events
	static func makeEvent( _ eventCategory:String, action:String, label:String, value:NSNumber ) {
		/*let tracker = GAI.sharedInstance().defaultTracker; tracker.allowIDFACollection = true;
		tracker.send(
			GAIDictionaryBuilder.createEventWithCategory(eventCategory, action: action, label: label, value: value).build()
			 as [AnyHashable: Any]
		);
		*/
	}
	
}
