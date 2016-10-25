//
//  AppDelegate.swift
//  UP
//
//  Created by ExFl on 2016. 1. 20..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import UIKit;
import AVFoundation;
import MediaPlayer;
import GameKit;
import UserNotifications;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	var window: UIWindow?;
	var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?;
	
	var alarmBackgroundTaskPlayer:AVAudioPlayer?;
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		//앱 실행시
		
		//Startup language initial
		print("Pref lang", (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String );
		Languages.initLanugages( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String );
		//Init DataManager
		DataManager.initDataManager();
		//Init CharacterMgr
		CharacterManager.merge();
		//Startup alarm merge
		AlarmManager.mergeAlarm();
		//achievementmanager init
		AchievementManager.initManager();
		//purchase init
		PurchaseManager.initManager();
		
		//Gogle Analytics active
		AnalyticsManager.initGoogleAnalytics();
		
		//Unityads init
		UnityAdsManager.initManager();
		
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().delegate = self;
		} else {
			// Fallback on earlier versions
		};
		
		//게임센터 초기화 및 뷰 표시
		if let presentVC = window?.rootViewController {
			let targetVC = presentVC;
			let player = GKLocalPlayer.localPlayer();
			player.authenticateHandler = {(viewController, error) -> Void in
				if ((viewController) != nil) {
					// Login phase start
					targetVC.present(viewController!, animated: true, completion: nil);
				} else {
					if (error == nil){
						print("Authentication: OK")
					} else {
						print("Authentication: Error")
					}
				}
			}
		} //fin
		
		
		
		
		return true;
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
	
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("App is now running to background");
		DeviceManager.appIsBackground = true;
		AlarmManager.mergeAlarm();
		/*if (AlarmListView.alarmListInited) {
			AlarmListView.selfView!.createTableList(); //refresh alarm-list
		}*/
		
		//// Background thread
		backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
			UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!);
		});
		
		//DISPATCH_QUEUE_PRIORITY_DEFAULT
		DispatchQueue.global(qos: .background).async {
		//DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: { () -> Void in
			if (self.alarmBackgroundTaskPlayer != nil) {
				self.alarmBackgroundTaskPlayer!.stop();
				self.alarmBackgroundTaskPlayer = nil;
			}
			
			let nsURL:URL = Bundle.main.url( forResource: "up_background_task_alarm" , withExtension: "mp3")!;
			do { self.alarmBackgroundTaskPlayer = try AVAudioPlayer(
				contentsOf: nsURL,
				fileTypeHint: nil
				);
			} catch let error as NSError {
				print(error.description);
			}
			//self.alarmBackgroundTaskPlayer!.numberOfLoops = -1;
			self.alarmBackgroundTaskPlayer!.prepareToPlay();
			//self.alarmBackgroundTaskPlayer!.play();

			while(DeviceManager.appIsBackground) {
				let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds();
				let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(Date().timeIntervalSince1970));
				let ringingAlarm:AlarmElements? = AlarmManager.getRingingAlarm();
				
				print( "thread remaining:", UIApplication.shared.backgroundTimeRemaining, ", remaining next alarm:", nextAlarmLeft );
				
				//이부분 수정해야함 - 켜져있는 알람 중 타임스탬프를 빼서 곧 울릴것 같은 알람을 알람매니저측에서 구현한 다음
				//만약 곧 울릴거 같다라고 판단되면 엄청 빠르게 백그라운드 태스크를 그때만 순간적으로 돌려서
				//사운드 울리는 타이밍의 어긋남을 줄여야함.
				
				//1. 알람이 울리는 중일 경우, 2. 백그라운드에 앱이 있을 경우.
				if (ringingAlarm != nil && DeviceManager.appIsBackground == true) {
					AlarmManager.ringSoundAlarm( ringingAlarm!, useVibrate: true );
					//vibrate to ringsoundalarm
					//print("Alarm ringing");
				} else {
					//울리고 있는 알람이 없는데 굳이 울려야 겠음?
					AlarmManager.stopSoundAlarm();
				}
				
				if (UIApplication.shared.backgroundTimeRemaining < 60) {
					self.alarmBackgroundTaskPlayer!.stop();
					self.alarmBackgroundTaskPlayer!.play();
					print("background thread - sound play");
				}
				
				if (ringingAlarm != nil && DeviceManager.appIsBackground == true) {
					Thread.sleep(forTimeInterval: 1); //1초 주기 실행
				} else {
					//남은 시간 비례하여 쓰레드 주기를 좁혀, 보다 정확한 시간에 알람이 울리게 함.
					if (nextAlarmLeft >= 0) {
						if (nextAlarmLeft > 90) {
							Thread.sleep(forTimeInterval: 30); //30초 주기 실행
						} else if (nextAlarmLeft > 30) {
							Thread.sleep(forTimeInterval: 10); //10
						} else if (nextAlarmLeft > 20) {
							Thread.sleep(forTimeInterval: 5); //5
						} else if (nextAlarmLeft > 3) {
							Thread.sleep(forTimeInterval: 1); //1
						} else if (nextAlarmLeft > 1) {
							Thread.sleep(forTimeInterval: 0.5); //0.5
						} else {
							Thread.sleep(forTimeInterval: 0.25); //0.25
						} //end if
					} else {
						Thread.sleep(forTimeInterval: 30); //30초 주기 실행
					} //end if
					
				} //end chk alarm vaild
			}
			//print("thread finished");
			
			if (self.alarmBackgroundTaskPlayer != nil) {
				self.alarmBackgroundTaskPlayer!.stop();
				self.alarmBackgroundTaskPlayer = nil;
			}
			UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!);
			
		};
		
		
		
		
		
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		DeviceManager.appIsBackground = false;
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
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
		//알람 게임뷰가 켜져있는 경우, 터치 지연 시간을 0으로 초기화
		if (AlarmRingView.selfView != nil) {
			AlarmRingView.selfView!.lastActivatedTimeAfter = 0;
		}
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	//func notific
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("Notifi called");
	}
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		print("Notifi responsed");
	}

}

