//
//  AppDelegate.swift
//  UP
//
//  Created by ExFl on 2016. 1. 20..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import UIKit;
import AVFoundation;
import MediaPlayer;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?;
	var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?;
	
	var alarmBackgroundTaskPlayer:AVAudioPlayer?;
	
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		//앱 실행시
		
		//Startup language initial
		print("Pref lang", NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String );
		Languages.initLanugages( NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String );
		//Startup alarm merge
		AlarmManager.mergeAlarm();
		
		//로컬알림 (등)으로인해 앱실행된경우.
		if let options = launchOptions {
			if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
				//queue with launchopt
				print("Launched with options.");
				AlarmManager.mergeAlarm();
				if (AlarmListView.alarmListInited) {
					AlarmListView.selfView!.createTableList(); //refresh alarm-list
				}
				
			}
		}
		
		return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
	
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("App is now running to background");
		DeviceGeneral.appIsBackground = true;
		AlarmManager.mergeAlarm();
		if (AlarmListView.alarmListInited) {
			AlarmListView.selfView!.createTableList(); //refresh alarm-list
		}
		
		//// Background thread
		backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
			UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!);
		});
		
		//DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
			if (self.alarmBackgroundTaskPlayer != nil) {
				self.alarmBackgroundTaskPlayer!.stop();
				self.alarmBackgroundTaskPlayer = nil;
			}
			
			let nsURL:NSURL = NSBundle.mainBundle().URLForResource( "up_background_task_alarm" , withExtension: "mp3")!;
			do { self.alarmBackgroundTaskPlayer = try AVAudioPlayer(
				contentsOfURL: nsURL,
				fileTypeHint: nil
				);
			} catch let error as NSError {
				print(error.description);
			}
			//self.alarmBackgroundTaskPlayer!.numberOfLoops = -1;
			self.alarmBackgroundTaskPlayer!.prepareToPlay();
			//self.alarmBackgroundTaskPlayer!.play();

			while(DeviceGeneral.appIsBackground) {
				print("background thread remaining:", UIApplication.sharedApplication().backgroundTimeRemaining);
				
				let ringingAlarm:AlarmElements? = AlarmManager.getRingingAlarm();
				
				//1. 알람이 울리는 중일 경우, 2. 백그라운드에 앱이 있을 경우.
				if (ringingAlarm != nil && DeviceGeneral.appIsBackground == true) {
					AlarmManager.ringSoundAlarm( ringingAlarm! );
					AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
					//print("Alarm ringing");
				} else {
					//울리고 있는 알람이 없는데 굳이 울려야 겠음?
					AlarmManager.stopSoundAlarm();
				}
				
				if (UIApplication.sharedApplication().backgroundTimeRemaining < 60) {
					self.alarmBackgroundTaskPlayer!.stop();
					self.alarmBackgroundTaskPlayer!.play();
					print("background thread - sound play");
				}
				
				if (ringingAlarm != nil && DeviceGeneral.appIsBackground == true) {
					NSThread.sleepForTimeInterval(1); //1초 주기 실행
				} else {
					NSThread.sleepForTimeInterval(10); //10초 주기 실행
				}
			}
			//print("thread finished");
			
			if (self.alarmBackgroundTaskPlayer != nil) {
				self.alarmBackgroundTaskPlayer!.stop();
				self.alarmBackgroundTaskPlayer = nil;
			}
			UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!);
			
		});
		
		
		
		
		
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		DeviceGeneral.appIsBackground = false;
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		print("App is active now");
		AlarmManager.mergeAlarm();
		
		if (AlarmListView.alarmListInited) {
			AlarmListView.selfView!.createTableList(); //refresh alarm-list
		}
		
		if (ViewController.viewSelf != nil) {
			ViewController.viewSelf!.checkToCallAlarmRingingView();
		}
		
		//알람이 울리고 있었다면 꺼줌.
		AlarmManager.stopSoundAlarm();
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

