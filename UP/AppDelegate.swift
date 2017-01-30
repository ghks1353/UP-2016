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
	
	var alarmBackgroundTaskPlayer:AVAudioPlayer?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		//앱 실행시
		
		//Startup language initial
		print("Pref lang", (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String )
		LanguagesManager.initLanugages( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String )
		//Init DataManager
		DataManager.initDataManager()
		//Init CharacterMgr
		CharacterManager.merge()
		//Startup alarm merge
		AlarmManager.mergeAlarm()
		//achievementmanager init
		AchievementManager.initManager()
		//purchase init
		PurchaseManager.initManager()
		
		//Unityads init
		UnityAdsManager.initManager()
		
		//Firebase init
		FIRApp.configure()
		
		//add observer to fir
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(self.tokenRefreshNotification),
		                                       name: .firInstanceIDTokenRefresh,
		                                       object: nil)
		
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().delegate = self
		} else {
			// Fallback on earlier versions
		}
		
		
		//게임센터 초기화 및 뷰 표시
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
		
		
		let nsURL:URL = Bundle.main.url( forResource: "up_background_task_alarm" , withExtension: "mp3")!
		do {
			self.alarmBackgroundTaskPlayer = try AVAudioPlayer( contentsOf: nsURL, fileTypeHint: nil )
		} catch let error as NSError {
			print(error.description)
		}
		alarmBackgroundTaskPlayer!.prepareToPlay()
		
		return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		print("App will background")
		DeviceManager.appIsBackground = true
    }
	
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("App is now running to background")
		DeviceManager.appIsBackground = true
		AlarmManager.mergeAlarm()
		
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
				
				print( "thread remaining:", UIApplication.shared.backgroundTimeRemaining, ", remaining next alarm:", nextAlarmLeft )
				
				//1. 알람이 울리는 중일 경우, 2. 백그라운드에 앱이 있을 경우.
				if (ringingAlarm != nil) {
					//Thread stop
					if (self.alarmBackgroundTaskPlayer!.isPlaying) {
						self.alarmBackgroundTaskPlayer!.stop()
					}
					
					AlarmManager.ringSoundAlarm( ringingAlarm!, useVibrate: true )
				} else {
					//울리고 있는 알람이 없는데 굳이 울려야 겠음?
					AlarmManager.stopSoundAlarm()
					
					//Thread play
					self.alarmBackgroundTaskPlayer!.stop()
					self.alarmBackgroundTaskPlayer!.play()
				}
				
				
				if (ringingAlarm != nil) {
					Thread.sleep(forTimeInterval: 1) //1초 주기 실행
				} else {
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
						} else if (nextAlarmLeft > 1) {
							Thread.sleep(forTimeInterval: 0.5) //0.5
						} else {
							Thread.sleep(forTimeInterval: 0.25) //0.25
						} //end if
					} else {
						Thread.sleep(forTimeInterval: 30) //30초 주기 실행
					} //end if
					
				} //end chk alarm vaild
			}
			//print("thread finished");
			
			UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
		}; //end thread
		
		
		
		
		
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		DeviceManager.appIsBackground = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		print("App is active now")
		AlarmManager.mergeAlarm()
		connectToFcm()
		/*if (AlarmListView.alarmListInited) {
			AlarmListView.selfView!.createTableList(); //refresh alarm-list
		}*/
		
		if (ViewController.selfView != nil) {
			ViewController.selfView!.checkToCallAlarmRingingView()
		}
		
		//알람이 울리고 있었다면 꺼줌.
		AlarmManager.stopSoundAlarm()
		//알람 게임뷰가 켜져있는 경우, 터치 지연 시간을 0으로 초기화
		if (AlarmRingView.selfView != nil) {
			AlarmRingView.selfView!.lastActivatedTimeAfter = 0
		}
		
		self.alarmBackgroundTaskPlayer!.stop()
		print("background thread - sound stop")

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	//func notific
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("Notifi called")
	}
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		print("Notifi responsed")
		
		let usrInfo = response.notification.request.content.userInfo
		handlePushMessage( usrInfo )
	}
	
	///////// FCM Register
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// With swizzling disabled you must set the APNs token here.
		/*
			setAPNSToken:type:에 APN 토큰 및 토큰 유형을 제공합니다. type의 값을 올바르게 설정해야 합니다. 샌드박스 환경의 경우 FIRInstanceIDAPNSTokenTypeSandbox, 운영 환경의 경우 FIRInstanceIDAPNSTokenTypeProd로 설정합니다. 유형을 잘못 설정하면 메시지가 앱에 전송되지 않습니다.
		*/
		//debug/production을 잘못 고르면
		//(즉 프로덕션에서 샌드박스 토큰 고르고 하면)
		//배터리가 이상하게 광탈함. 구글쪽 문제임
		
		#if DEBUG
			print("Using debug mode.")
			//usb 연결해서 테스트하는거면 sandbox 사용
			FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.sandbox)
		#else
			print("Using release mode.")
			//앱스토어에 올리거나 애드혹인 경우 prod 사용
			FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.prod)
		#endif
	} //end func
	/////////// FCM Receive
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
		print("Received pushmsg")
		
		handlePushMessage( userInfo )
	} //end func
	func tokenRefreshNotification(_ notification: Notification) {
		if let refreshedToken = FIRInstanceID.instanceID().token() {
			print("InstanceID token: \(refreshedToken)")
		}
		
		// Connect to FCM since connection may have failed when attempted before having a token.
		connectToFcm()
	}
	func connectToFcm() {
		// Won't connect since there is no token
		guard FIRInstanceID.instanceID().token() != nil else {
			return;
		}
		
		// Disconnect previous FCM connection if it exists.
		FIRMessaging.messaging().disconnect()
		
		FIRMessaging.messaging().connect { (error) in
			if error != nil {
				print("Unable to connect with FCM. \(error)")
			} else {
				print("Connected to FCM.")
				FIRMessaging.messaging().subscribe(toTopic: FirebaseTopicManager.Topics.GeneralUser.rawValue)
			}
		}
	}
	//////////////////
	func handlePushMessage(_ usrInfo:[AnyHashable : Any]? ) {
		//Handling push/local notify
		if (usrInfo == nil) {
			print("Can't handle push message because userinfo is null")
			return
		}
		
		if (usrInfo!["type"] == nil) {
			print("Can't handle push message because type is null")
			return
		}
		
		switch( String(describing: usrInfo!["type"]!) ) {
			case "link":
				let targetURL:String? = usrInfo!["url"] as! String?
				if (targetURL != nil) {
					ViewController.selfView!.showWebViewModal( url: targetURL! )
				}
				break
			default:
				print("Can't handle push message because type is unknown. type:", usrInfo!["type"]!)
				break
		} //end switch
		
		print("url:" + String(describing: usrInfo!["url"] ))
	} //end func
}

