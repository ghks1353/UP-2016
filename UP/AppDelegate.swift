//
//  AppDelegate.swift
//  UP
//
//  Created by ExFl on 2016. 1. 20..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import GameKit
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	var window: UIWindow?
	var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
	
	//Alarm background task bgm player
	var alarmBackgroundTaskPlayer:AVAudioPlayer?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		//앱 실행시
		
		//Startup language initial
		//print("Pref lang", (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String )
		LanguagesManager.initLanugages( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String )
		//Init DataManager
		DataManager.initDataManager()
		//Theme init
		ThemeManager.initManager()
		//Startup alarm merge
		AlarmManager.mergeAlarm()
		//Init CharacterMgr
		CharacterManager.merge()
		//achievementmanager init
		AchievementManager.initManager()
		//purchase init
		PurchaseManager.initManager()
		//Unityads init
		UnityAdsManager.initManager()
		//Firebase init
		FirebaseApp.configure()
		//Firebase remoteconfig init
		RemoteConfigManager.initManager()
		
		//Fetch custom sound list
		SoundManager.fetchCustomSoundsList()
		
		//add observer to fir
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(self.tokenRefreshNotification),
		                                       name: NSNotification.Name.InstanceIDTokenRefresh,
		                                       object: nil)
		
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().delegate = self
		} else {
			// Fallback on earlier versions
		}
		
		
		//게임센터 초기화 및 뷰 표시
		/*
		if (window?.rootViewController) != nil {
			//let targetVC = presentVC;
			let player = GKLocalPlayer.localPlayer()
			player.authenticateHandler = {(viewController, error) -> Void in
				if ((viewController) != nil) {
					// Login phase start
					//targetVC.present(viewController!, animated: true, completion: nil);
				} else {
					if (error == nil){
						print("Authentication: OK")
					} else {
						print("Authentication: Error")
					}
				}
			}
		} //fin
		*/
		
		let nsURL:URL = Bundle.main.url( forResource: "up_background_task_alarm" , withExtension: "mp3")!
		do {
			self.alarmBackgroundTaskPlayer = try AVAudioPlayer( contentsOf: nsURL, fileTypeHint: nil )
		} catch let error as NSError {
			print(error.description)
		}
		alarmBackgroundTaskPlayer!.prepareToPlay()
		
		print("[UP] Application inited!")
		return true
    } //end func

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		print("[UP] App will background")
		DeviceManager.appIsBackground = true
		AlarmManager.mergeAlarm()
		Messaging.messaging().disconnect()
		
		SoundManager.setAudioPlayback( .AlarmMode )
	}
	
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("[UP] App is now running to background")
		DeviceManager.appIsBackground = true
		
		SoundManager.setAudioPlayback( .AlarmMode )
		
		//// Background thread
		backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
			UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
		})
		
		//DISPATCH_QUEUE_PRIORITY_DEFAULT
		DispatchQueue.global(qos: .background).async {
			while(DeviceManager.appIsBackground) {
				let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds()
				let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(Date().timeIntervalSince1970))
				let ringingAlarm:AlarmElements? = AlarmManager.getRingingAlarm()
				
				print( "[Background] t:", UIApplication.shared.backgroundTimeRemaining, "/ next:", nextAlarmLeft )
				
				//1. 알람이 울리는 중일 경우, 2. 백그라운드에 앱이 있을 경우.
				if (ringingAlarm != nil) {
					//Thread stop
					if (self.alarmBackgroundTaskPlayer!.isPlaying) {
						self.alarmBackgroundTaskPlayer!.stop()
					}
					
					//노티피 제거후 다시생성
					AlarmManager.refreshLocalNotifications()
					AlarmManager.ringSoundAlarm( ringingAlarm!, useVibrate: true )
					
					Thread.sleep(forTimeInterval: 1) //1초 주기 실행
				} else {
					//울리고 있는 알람이 없는데 굳이 울려야 겠음?
					AlarmManager.stopSoundAlarm()
					
					//Background 유지를 위한 Thread play
					self.alarmBackgroundTaskPlayer!.stop()
					self.alarmBackgroundTaskPlayer!.play()
					
					//남은 시간 비례하여 쓰레드 주기를 좁혀, 보다 정확한 시간에 알람이 울리게 함.
					if (nextAlarmLeft >= 0) {
						if (nextAlarmLeft > 90) {
							Thread.sleep(forTimeInterval: 30) //30초 주기 실행
						} else if (nextAlarmLeft > 30) {
							Thread.sleep(forTimeInterval: 10) //10
						} else if (nextAlarmLeft > 20) {
							Thread.sleep(forTimeInterval: 5) //5
						} else if (nextAlarmLeft > 3) {
							Thread.sleep(forTimeInterval: 1) //1
						} else {
							AlarmManager.refreshLocalNotifications()
							Thread.sleep(forTimeInterval: 0.5) //0.5
						}
					} else {
						Thread.sleep(forTimeInterval: 30) //30초 주기 실행
					} //end if [alarm left]
				} //end if [alarm valid]
				
				
			} //end while
			UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
		}; //end thread
		
		
		
    } //end func

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		DeviceManager.appIsBackground = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		print("[UP] App is active now")
		DeviceManager.appIsBackground = false
		
		//Merge alarms
		AlarmManager.mergeAlarm()
		//Force add notifications
		AlarmManager.refreshLocalNotifications( true )
		SoundManager.setAudioPlayback( .NormalMode )
		
		//알람이 울리고 있었다면 꺼줌.
		AlarmManager.stopSoundAlarm()
		
		//Connect to FCM Server
		connectToFcm()
		
		//알람 게임뷰가 켜져있는 경우, 터치 지연 시간을 0으로 초기화
		if (AlarmRingView.selfView != nil) {
			AlarmRingView.selfView!.lastActivatedTimeAfter = 0
		}
		
		//verify product if available
		PurchaseManager.autoVerifyPurchases()
		
		self.alarmBackgroundTaskPlayer!.stop()
    } //end func

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	//func notific
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("[UP] Notifi called")
	}
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		print("[UP] Notifi responsed")
		
		let usrInfo = response.notification.request.content.userInfo
		handlePushMessage( usrInfo )
	}
	
	///////// FCM Register
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// With swizzling disabled you must set the APNs token here.
		//debug/production을 잘못 고르면
		//(즉 프로덕션에서 샌드박스 토큰 고르고 하면)
		//배터리가 이상하게 광탈함. 구글쪽 문제임
		
		#if DEBUG
			print("[UP] FIRInstance APS using debug mode.")
			//usb 연결해서 테스트하는거면 sandbox 사용
			Messaging.messaging().setAPNSToken(deviceToken as Data, type: MessagingAPNSTokenType.sandbox)
		#else
			print("[UP] FIRInstance APS using release mode.")
			//앱스토어에 올리거나 애드혹인 경우 prod 사용
			Messaging.messaging().setAPNSToken(deviceToken as Data, type: MessagingAPNSTokenType.prod)
		#endif
	} //end func
	/////////// FCM Receive
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
		print("[UP] Received pushmsg")
		
		Messaging.messaging().appDidReceiveMessage( userInfo )
		handlePushMessage( userInfo )
	} //end func
	func tokenRefreshNotification(_ notification: Notification) {
		if let refreshedToken = InstanceID.instanceID().token() {
			print("[UP] InstanceID token: \(refreshedToken)")
		}
		
		// Connect to FCM since connection may have failed when attempted before having a token.
		connectToFcm()
	}
	func connectToFcm() {
		// Won't connect since there is no token
		guard InstanceID.instanceID().token() != nil else {
			return
		}
		
		// Connect to FCM Channel
		Messaging.messaging().shouldEstablishDirectChannel = true
		
		if (Messaging.messaging().isDirectChannelEstablished) {
			print("[UP] Connected to FCM.")
			Messaging.messaging().subscribe(toTopic: FirebaseTopicManager.Topics.GeneralUser.rawValue)
		} // end if
		
	} // end func
	//////////////////
	func handlePushMessage(_ usrInfo:[AnyHashable : Any]? ) {
		//Handling push/local notify
		if (usrInfo == nil) {
			print("[UP] Can't handle push message because userinfo is null")
			return
		}
		
		if (usrInfo!["type"] == nil) {
			print("[UP] Can't handle push message because type is null")
			return
		}
		
		switch( String(describing: usrInfo!["type"]!) ) {
			case "link":
				let targetURL:String? = usrInfo!["url"] as! String?
				if (targetURL != nil) {
					if (ViewController.selfView != nil) {
						ViewController.selfView!.showWebViewModal( url: targetURL! )
					} //end if [viewcontroller instance is nil or not]
					else {
						print("[UP] ViewController instance is not inited")
					}
				} //end if [targeturl is nil or not]
				break
			default:
				print("[UP] Can't handle push message because type is unknown. type:", usrInfo!["type"]!)
				break
		} //end switch
		
	} //end func
} //end class
