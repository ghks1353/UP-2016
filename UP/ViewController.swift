//
//  ViewController.swift
//  UP
//
//  Created by ExFl on 2016. 1. 20..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import UserNotifications

import SQLite
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class ViewController: UIViewController {
	
	static var selfView:ViewController?
	
	//Modal views
	var modalSettingsView:SettingsView = SettingsView()
	var modalAlarmListView:AlarmListView = AlarmListView()
	var modalAlarmAddView:AddAlarmView = GlobalSubView.alarmAddView
	var modalAlarmStatsView:StatisticsView = StatisticsView()
	var modalCharacterInformationView:CharacterInfoView = CharacterInfoView()
	var modalPlayGameview:GamePlayView = GamePlayView()
	var modalGameResultView:GameResultView = GlobalSubView.alarmGameResultView
	var modalGamePlayWindowView:GamePlayWindowView = GlobalSubView.alarmGamePlayWindowView
	var modalWebView:ModalWebView = ModalWebView()
	var modalBuyExPackView:BuyExPackView = BuyExPackView()
	
	//Overlay view
	var overlayGuideView:MainOverlayGuideView = MainOverlayGuideView()
	
	//Digital 시계
	var DigitalNum0:UIImageView = UIImageView(); var DigitalNum1:UIImageView = UIImageView();
	var DigitalNum2:UIImageView = UIImageView(); var DigitalNum3:UIImageView = UIImageView();
	var DigitalCol:UIImageView = UIImageView()
	//Digital clock wrapper for align to center
	var digitalClockUIView:UIView = UIView()
	
	//Digital clock image cache block
	var digitalClockImageCached:Array<UIImage> = []
	var digitalClockAMPMCached:Array<UIImage> = []
	
	//AM / PM
	var digitalAMPMIndicator:UIImageView = UIImageView()
	var digitalCurrentIsPM:Int = -1 //am이면 0, pm이면 1
	
	//아날로그 시계
	var AnalogBody:UIImageView = UIImageView(); var AnalogHours:UIImageView = UIImageView();
	var AnalogMinutes:UIImageView = UIImageView(); var AnalogSeconds:UIImageView = UIImageView();
	var AnalogCenter:UIImageView = UIImageView();
	
	//아날로그 시계 좌우 버튼
	var SettingsImg:UIImageView = UIImageView(); var AlarmListImg:UIImageView = UIImageView();
	
	//땅 부분
	var GroundObj:UIImageView = UIImageView(); var AstroCharacter:UIImageView = UIImageView();
	var GroundStatSign:UIImageView = UIImageView(); //통계 사인
	//고정 박스와 떠있는 박스 (게임쪽)
	var GroundStandingBox:UIImageView = UIImageView(); var GroundFloatingBox:UIImageView = UIImageView();
	
	///////////// Touch areas
	var touchAreaPlayGame:UIView = UIView() //게임하기 touch area
	var touchAreaAnalogBody:UIView = UIView() //시계 touch area
	var touchAreaStatistics:UIView = UIView() //통계 touch area
	
	//스탠딩 모션
    var astroMotionsStanding:Array<UIImage> = []
	
	//////////
	//뒷 배경 이미지 (시간에 따라 변경되며 변경 시간대마다 한번씩 fade)
	var backgroundImageView:UIImageView = UIImageView()
	var backgroundImageFadeView:UIImageView = UIImageView()
	var currentBackgroundImage:String = ThemeManager.ThemeFileNames.BackgroundMorning //default background
	var currentGroundImage:String = ThemeManager.ThemeFileNames.GroundMorning //default ground
	
	///// 메인 애니메이션용 값 저장 배열.
	var mainAnimatedObjs:Array<AnimatedImg> = Array<AnimatedImg>()
	
	//위쪽에서 내려오는 알람 메시지를 위한 뷰
	var upAlarmMessageView:UIView = UIView()
	var upAlarmMessageText:UILabel = UILabel()
	
	//UP 확장팩 구매 유도 버튼 및 도움말 표시 버튼
	var upExtPackButton:UIImageView = UIImageView()
	var upLayerGuideShowButton:UIImageView = UIImageView()
	
	//screen blur view
	var scrBlurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
	
	//// 앱 실행 시 한번만, 웹브라우저 띄우기 (공지사항 같은)
	var isNoticeCalled:Bool = false
	
    //viewdidload - inital 함수. 뷰 로드시 자동실행
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//statusbar
		UIApplication.shared.setStatusBarHidden(false, with: .fade)
		
		//Init device size factor
        DeviceManager.initialDeviceSize()
		
		//클래스 외부접근
		ViewController.selfView = self
		
		//Startup permission request
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().requestAuthorization(
				options: [.alert,.sound,.badge],
				completionHandler: { (granted,error) in
					if (error == nil) {
						UIApplication.shared.registerForRemoteNotifications()
					} else {
						//alarm auth regist fallback 넣어야함 (알림설정 해주세요)
					} //end if
				}
			)
		} else {
			// Fallback on earlier versions
			let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			UIApplication.shared.registerUserNotificationSettings(notificationSettings)
			UIApplication.shared.registerForRemoteNotifications()
		}
		
		
		//Background image add.
		self.view.addSubview(backgroundImageView); self.view.addSubview(backgroundImageFadeView);
		self.view.sendSubview(toBack: backgroundImageFadeView); self.view.sendSubview(toBack: backgroundImageView);
		
		//리소스 뷰에 추가
		digitalClockUIView.addSubview(DigitalNum0)
		digitalClockUIView.addSubview(DigitalNum1)
		digitalClockUIView.addSubview(DigitalNum2)
		digitalClockUIView.addSubview(DigitalNum3)
		digitalClockUIView.addSubview(DigitalCol)
		
		self.view.addSubview( digitalClockUIView )
		self.view.addSubview( digitalAMPMIndicator )
		
		self.view.addSubview(AnalogBody); self.view.addSubview(AnalogHours);
		self.view.addSubview(AnalogMinutes); self.view.addSubview(AnalogSeconds);
		self.view.addSubview(AnalogCenter);
		
		self.view.addSubview(SettingsImg); self.view.addSubview(AlarmListImg);
		
		self.view.addSubview(GroundObj); self.view.addSubview(AstroCharacter);
		self.view.addSubview(GroundStatSign);
		
		self.view.addSubview(GroundStandingBox); self.view.addSubview(GroundFloatingBox);
		
		//UP 구매버튼, 가이드 보기 버튼
		self.view.addSubview(upExtPackButton)
		self.view.addSubview(upLayerGuideShowButton)
		
		//////////////////
		//Add toucharea
		touchAreaAnalogBody.backgroundColor = UIColor.clear
		touchAreaPlayGame.backgroundColor = UIColor.clear
		touchAreaStatistics.backgroundColor = UIColor.clear
		
		self.view.addSubview(touchAreaPlayGame)
		self.view.addSubview(touchAreaAnalogBody)
		self.view.addSubview(touchAreaStatistics)
		
		//리소스 우선순위 설정
		self.view.bringSubview(toFront: digitalClockUIView)
		self.view.bringSubview(toFront: digitalAMPMIndicator)
		
		self.view.bringSubview(toFront: AnalogBody)
		self.view.bringSubview(toFront: AnalogHours); self.view.bringSubview(toFront: AnalogMinutes);
		self.view.bringSubview(toFront: AnalogSeconds); self.view.bringSubview(toFront: AnalogCenter);
		
		self.view.bringSubview(toFront: GroundObj); self.view.bringSubview(toFront: AstroCharacter);
		self.view.bringSubview(toFront: GroundStatSign)
		
		self.view.bringSubview(toFront: GroundStandingBox); self.view.bringSubview(toFront: GroundFloatingBox);
		
		
		self.view.bringSubview(toFront: touchAreaAnalogBody)
		self.view.bringSubview(toFront: touchAreaPlayGame)
		self.view.bringSubview(toFront: touchAreaStatistics)
		
		/////////
		//일부 리소스 이미지 미리 지정
		upExtPackButton.image = UIImage( named: "comp-buyup-icon.png" )
		upLayerGuideShowButton.image = UIImage( named: "comp-showguide-icon.png" )
		
		//디지털시계 이미지 기본 설정
		/*DigitalCol.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + "col.png" )
		DigitalNum0.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + "0.png" )
		DigitalNum1.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + "0.png" )
		DigitalNum2.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + "0.png" )
		DigitalNum3.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + "0.png" )
		DigitalCol.frame.size = CGSize( width: 43.5, height: 60.9 ); //디바이스별 크기 설정은 밑에서 하므로 여긴 원본 크기를 입력함.
		*/
		
		if (DeviceManager.is24HourMode == true) {
			digitalAMPMIndicator.isHidden = true //24시간에선 오전오후 표시필요가 없음
		}
		
		//기본 스킨 선택.
		updateTheme()
		
		//Element fit to screen
		fitViewControllerElementsToScreen( false )
		
		//기본 스킨이 선택된 상태에서
        AstroCharacter.animationImages = astroMotionsStanding
        AstroCharacter.animationDuration = 1.0
		AstroCharacter.animationRepeatCount = -1
        AstroCharacter.startAnimating()
		
		//////////////////// 터치 인터렉션 (메뉴 이동)
		
        //시계 이미지 터치시
        var tGests = UITapGestureRecognizer(target:self, action:#selector(self.openAlarmaddView(_:))) //openAlarmaddView
        touchAreaAnalogBody.isUserInteractionEnabled = true
        touchAreaAnalogBody.addGestureRecognizer(tGests)
        
        //환경설정 아이콘 터치시
        tGests = UITapGestureRecognizer(target:self, action:#selector(self.openSettingsView(_:)))
        SettingsImg.isUserInteractionEnabled = true
        SettingsImg.addGestureRecognizer(tGests)
        
        //리스트 아이콘 터치시
        tGests = UITapGestureRecognizer(target:self, action:#selector(self.openAlarmlistView(_:)))
        AlarmListImg.isUserInteractionEnabled = true
        AlarmListImg.addGestureRecognizer(tGests)
		
		//통계 아이콘 터치시
		tGests = UITapGestureRecognizer(target:self, action:#selector(self.openStatisticsView(_:)))
		touchAreaStatistics.isUserInteractionEnabled = true
		touchAreaStatistics.addGestureRecognizer(tGests)
		
		//Astro 터치 시
		tGests = UITapGestureRecognizer(target:self, action:#selector(self.openCharacterInformationView(_:)))
		AstroCharacter.isUserInteractionEnabled = true
		AstroCharacter.addGestureRecognizer(tGests)
		
		//게임 박스 터치시
		tGests = UITapGestureRecognizer(target:self, action:#selector(self.openGamePlayView(_:)))
		touchAreaPlayGame.isUserInteractionEnabled = true
		touchAreaPlayGame.addGestureRecognizer(tGests)
		
		//가이드 버튼 터치시
		tGests = UITapGestureRecognizer(target:self, action:#selector(self.showGuideView(_:)))
		upLayerGuideShowButton.isUserInteractionEnabled = true
		upLayerGuideShowButton.addGestureRecognizer(tGests)
		
		//UP 구매 버튼 터치시
		tGests = UITapGestureRecognizer(target:self, action:#selector(self.showUPBuyView(_:)))
		upExtPackButton.isUserInteractionEnabled = true
		upExtPackButton.addGestureRecognizer(tGests)
		
		
		//////////////////////////////////////
		
		//iOS8 blur effect
		scrBlurView.frame = self.view.bounds
		scrBlurView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
		scrBlurView.translatesAutoresizingMaskIntoConstraints = true
		
		//FOR TEST
		//UIApplication.sharedApplication().cancelAllLocalNotifications();
		//AlarmManager.clearAlarm();
		/*
		do {
			for user in try DataManager.db()!.prepare(
				DataManager.gameResultTable()
					.order( Expression<Int64>("id").desc )
					.limit(2, offset: 0)
				) {
				print("id: ", user[Expression<Int64>("id")])
			}
			
			try DataManager.db()!.run(
				DataManager.gameResultTable()
					.filter(Expression<Int64>("id") == 83 || Expression<Int64>("id") == 82)
				.delete()
			)
		} catch {
			
		}*/
		
		//일반적인 사운드 재생 모드
		SoundManager.setAudioPlayback(.NormalMode)
		
		//Upside message initial
		upAlarmMessageView.backgroundColor = UIColor.white //color initial
		upAlarmMessageText.textColor = UIColor.black
		
		upAlarmMessageText.text = ""
		upAlarmMessageText.textAlignment = .center
		upAlarmMessageView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: 48)
		upAlarmMessageText.frame = CGRect(x: 0, y: 12, width: DeviceManager.scrSize!.width, height: 24)
		upAlarmMessageText.font = UIFont.systemFont(ofSize: 16)
		upAlarmMessageView.addSubview(upAlarmMessageText)
		
		self.view.addSubview( upAlarmMessageView )
		upAlarmMessageView.isHidden = true
		///// upside message inital
		
		//애니메이션을 위해 배열에 넣음
		mainAnimatedObjs += [
			AnimatedImg(targetView: GroundFloatingBox, defaultMovFactor: 1.0, defaultMovMaxFactor: 8.0, defaultMovRandomFactor: 1.0)
		]
		
		///////// start update task
		updateTimeAnimation() //first call
		_ = UPUtils.setInterval(0.5, block: updateTimeAnimation)
		
		//test
		//CharacterManager.giveEXP(4);
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false
    } //end viewdidload
	
	override func viewWillAppear(_ animated: Bool) {
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//Check alarms
		if (checkToCallAlarmRingingView()) {
			return
		} //end if
		
		//스타트가이드를 안 보았으면 강제로 보여주기
		if (DataManager.getSavedDataBool( DataManager.settingsKeys.startGuideFlag ) == false) {
			GlobalSubView.startingGuideView.modalPresentationStyle = .overFullScreen
			self.present(GlobalSubView.startingGuideView, animated: true, completion: nil)
			//modal call의 경우 스타트가이드를 보여준 상태에서는 스타트가이드 종료시 보여주도록 함
		} else {
			//스타트가이드를 이미 본 상태이면
			callShowNoticeModal()
		} //end if
	} //end func
	
	func showHideBlurview( _ show:Bool ) {
		
		//Show or hide blur
		if (show) {
			self.view.addSubview(scrBlurView)
			scrBlurView.alpha = 0;
			UIView.animate(withDuration: 0.32, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
				self.scrBlurView.alpha = 0.8
			}, completion: nil)
		} else {
			self.scrBlurView.alpha = 0.8;
			UIView.animate(withDuration: 0.32, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.scrBlurView.alpha = 0
				}, completion: {_ in
					self.scrBlurView.removeFromSuperview()
			})
		}
	} //end func
	
	func openAlarmaddView (_ gst: UITapGestureRecognizer) {
		
		//알람추가뷰 열기. 일단 최대 초과하는지 체크함
		if ( AlarmManager.alarmsArray.count >= AlarmManager.alarmMaxRegisterCount ) {
			//초과하므로, 열 수 없음
			
			let alarmCantAddAlert = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("informationAlarmExceed"), preferredStyle: UIAlertControllerStyle.alert)
			alarmCantAddAlert.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
				//Nothing do
			}))
			present(alarmCantAddAlert, animated: true, completion: nil)
			
		} else {
			modalAlarmAddView.modalPresentationStyle = .overFullScreen
			
			showHideBlurview(true)
			self.present(modalAlarmAddView, animated: false, completion: nil)
			modalAlarmAddView.clearComponents()
		} //end if
		
	} //end func
	
    func openSettingsView (_ gst: UITapGestureRecognizer) {
        //환경설정 열기
		modalSettingsView.modalPresentationStyle = .overFullScreen
		
		showHideBlurview(true)
        self.present(modalSettingsView, animated: false, completion: nil)
		modalSettingsView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) //scroll to top
    }
	
    func openAlarmlistView (_ gst: UITapGestureRecognizer) {
        //Alarmlist view 열기
		modalAlarmListView.modalPresentationStyle = .overFullScreen
		showHideBlurview(true)
		
        self.present(modalAlarmListView, animated: false, completion: nil)
		modalAlarmListView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) //scroll to top
    }
	
	func openStatisticsView (_ gst: UITapGestureRecognizer) {
		//Stats 열기
		modalAlarmStatsView.modalPresentationStyle = .overFullScreen
		showHideBlurview(true)
		
		self.present(modalAlarmStatsView, animated: false, completion: nil)
		modalAlarmStatsView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) //scroll to top
	}
	
	func openCharacterInformationView(_ gst: UITapGestureRecognizer) {
		//Character information 열기
		modalCharacterInformationView.modalPresentationStyle = .overFullScreen
		showHideBlurview(true)
		
		self.present(modalCharacterInformationView, animated: false, completion: nil)
	} //end func
	
	func openGamePlayView(_ gst: UITapGestureRecognizer!) {
		//GamePlay View 열기
		modalPlayGameview.modalPresentationStyle = .overFullScreen
		showHideBlurview(true)
		
		self.present(modalPlayGameview, animated: false, completion: nil)
	} //end func
	
	func showUPBuyView( _ gst:UITapGestureRecognizer? ) {
		modalBuyExPackView.modalPresentationStyle = .overFullScreen
		showHideBlurview(true)
		
		self.present(modalBuyExPackView, animated: false, completion: nil)
	} //end func
	
	////////////////////////////////////
  
    func updateTimeAnimation() {
        //setinterval call
		if (DeviceManager.appIsBackground == true) {
			return //배터리타임 아끼기 위해 실행 중단
		}
		if (AlarmManager.alarmRingActivated == true) {
			return
		} //알람 실행 중이면 함수 무시
		//// Check ringing alarm
		if (checkToCallAlarmRingingView()) {
			return
		} //end if
		
        //get time and calcuate
        let components = Calendar.current.dateComponents([ .hour, .minute, .second], from: Date())
        
		var hourString:String = ""
		var minString:String = ""
		
		if (DeviceManager.is24HourMode == true) {
			//24시간 시, 문자 그대로 표시
			hourString = String(describing: components.hour!)
		} else {
			//12시간 시, 12만큼 짜름
			hourString = String(components.hour! > 12 ? components.hour! - 12 : (components.hour! == 0 ? 12 : components.hour)!)
		} //end if [is 24h or not]
		minString = String(describing: components.minute!)
		//minString = String(describing: components.second!)
		
		//fix string if length is 1
		hourString = hourString.characters.count == 1 ? "0" + hourString : hourString
		minString = minString.characters.count == 1 ? "0" + minString : minString
		
		//AMPM check
		if (components.hour! >= 12) {
			if (digitalCurrentIsPM != 1) {
				digitalAMPMIndicator.image = digitalClockAMPMCached[1]
			}
			digitalCurrentIsPM = 1
		} else {
			if (digitalCurrentIsPM != 0) {
				//change
				digitalAMPMIndicator.image = digitalClockAMPMCached[0]
			}
			digitalCurrentIsPM = 0
		} //end if is am/pm
		
		//Time image attach
		DigitalNum0.image = digitalClockImageCached[ Int(hourString[0])! ]
		DigitalNum1.image = digitalClockImageCached[ Int(hourString[1])! ]
		DigitalNum2.image = digitalClockImageCached[ Int(minString[0])! ]
		DigitalNum3.image = digitalClockImageCached[ Int(minString[1])! ]
		
		////// 숫자 1 크기: 24
		////// : 크기: 8
		/////// 나머지 크기: 40
		//1칸 간격은 8.
		
		//숫자 1 배치시 (40 - 24) / 2
		//: 배치시 (40 - 8) / 2
		//y: DigitalCol.frame.minY
		let tNumFMargin:CGFloat = -((40 - 24) / 2) * DeviceManager.maxScrRatioC
		let tColMargin:CGFloat = -((40 - 8) / 2) * DeviceManager.maxScrRatioC
		let tNumMargin:CGFloat = 8 * DeviceManager.maxScrRatioC
		
		DigitalNum0.frame = CGRect(x: hourString[0] == "1" ? tNumFMargin : 0
			, y: 0, width: DigitalCol.frame.width, height: DigitalCol.frame.height)
		DigitalNum1.frame = CGRect(x: hourString[1] == "1" ? DigitalNum0.frame.maxX + tNumFMargin + (tNumMargin * ( hourString[0] == "1" ? 0 : 1 )) : DigitalNum0.frame.maxX + (tNumMargin * ( hourString[0] == "1" ? 0 : 1 ))
			, y: 0, width: DigitalCol.frame.width, height: DigitalCol.frame.height)
		
		// : 위치 조절
		DigitalCol.frame = CGRect(x: DigitalNum1.frame.maxX + tColMargin + (tNumMargin * ( hourString[1] == "1" ? 0 : 1 ))
			, y: 0, width: DigitalCol.frame.width, height: DigitalCol.frame.height)
		
		DigitalNum2.frame = CGRect(x: minString[0] == "1" ? (DigitalCol.frame.maxX + tColMargin) + tNumFMargin + tNumMargin : (DigitalCol.frame.maxX + tColMargin) + tNumMargin
			, y: 0, width: DigitalCol.frame.width, height: DigitalCol.frame.height)
		DigitalNum3.frame = CGRect(x: minString[1] == "1" ? DigitalNum2.frame.maxX + tNumFMargin + (tNumMargin * ( minString[0] == "1" ? 0 : 1 )) : DigitalNum2.frame.maxX + (tNumMargin * ( minString[0] == "1" ? 0 : 1 ))
			, y: 0, width: DigitalCol.frame.width, height: DigitalCol.frame.height)
		
		//col animation
        if (DigitalCol.isHidden) {
            //1초주기 실행
            let secondmov:Double = Double(components.minute!) / 60 / 12
            AnalogHours.transform = CGAffineTransform(rotationAngle: CGFloat(((Double(components.hour!) / 12) + secondmov) * 360) * CGFloat(M_PI) / 180 )
            AnalogMinutes.transform = CGAffineTransform(rotationAngle: CGFloat((Double(components.minute!) / 60) * 360) * CGFloat(M_PI) / 180 )
			AnalogSeconds.transform = CGAffineTransform(rotationAngle: CGFloat((Double(components.second!) / 60) * 360) * CGFloat(M_PI) / 180 )
        } //end if
        DigitalCol.isHidden = !DigitalCol.isHidden
		
		let dClockMinX:CGFloat = hourString[0] == "1" ? DigitalNum0.frame.minX + tNumMargin : DigitalNum0.frame.minX
		let dClockMaxX:CGFloat = minString[1] == "1" ? DigitalNum3.frame.maxX - tNumMargin : DigitalNum3.frame.maxX
		
		/// align to center 
		digitalClockUIView.frame = CGRect( x: DeviceManager.scrSize!.width / 2 - (dClockMaxX - dClockMinX) / 2, y: digitalClockUIView.frame.minY, width: dClockMaxX - dClockMinX, height: DigitalNum0.frame.height )
		
		
		if (GroundObj.image == nil) { // 이미지 없을 경우 땅 표시
			currentGroundImage = getBackground(components.hour!, isGround: true)
			if (UIDevice.current.userInterfaceIdiom == .phone) {
				GroundObj.image = UIImage( named:
					ThemeManager.getAssetPresets(themeGroup: .Background) + ThemeManager.getName(currentGroundImage) )
			} else {
				GroundObj.image = UIImage( named:
					ThemeManager.getAssetPresets(themeGroup: .Background) + currentGroundImage + ThemeManager.getName( (DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape) )
			} //end if
		} else {
			// 이미지 있을 경우 변경
			if (currentGroundImage != getBackground(components.hour!, isGround: true)) {
				//시간대가 바뀌어야 하는 경우
				currentGroundImage = getBackground(components.hour!, isGround: true) //시간대 이미지 변경
				if (UIDevice.current.userInterfaceIdiom == .phone) {
					GroundObj.image = UIImage( named:
						ThemeManager.getAssetPresets(themeGroup: .Background) + ThemeManager.getName(currentGroundImage) )
				} else {
					GroundObj.image = UIImage( named:
						ThemeManager.getAssetPresets(themeGroup: .Background) + currentGroundImage + ThemeManager.getName( (DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape) )
				} //end if
			} //end if [background time mismatch]
		} //end if [ground image is null or not]
		if (backgroundImageView.image == nil) { //이미지가 없을 경우 새로 표시.
			currentBackgroundImage = getBackground(components.hour!)
			print("current", UIApplication.shared.statusBarOrientation == .portrait)
			if (UIDevice.current.userInterfaceIdiom == .phone) {
				print("showing phone bg")
				backgroundImageView.image = UIImage( named:
					ThemeManager.getAssetPresets(themeGroup: .Background) + currentBackgroundImage + (
					DeviceManager.isiPhone4S ? ThemeManager.ThemePresets.iPhone4S : ""
					) )
				backgroundImageFadeView.image = UIImage( named:
					ThemeManager.getAssetPresets(themeGroup: .Background) + currentBackgroundImage + (
					DeviceManager.isiPhone4S ? ThemeManager.ThemePresets.iPhone4S : ""
					) )
			} else {
				print("showing pad bg")
				backgroundImageView.image = UIImage( named:
					ThemeManager.getAssetPresets(themeGroup: .Background) + currentBackgroundImage + (
					(DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape
					) )
				backgroundImageFadeView.image = UIImage( named:
					ThemeManager.getAssetPresets(themeGroup: .Background) + currentBackgroundImage + (
					(DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape
					) )
			} //end if [phone or not]
			
			backgroundImageFadeView.alpha = 0
			print("Scrsize",DeviceManager.scrSize!.height, (DeviceManager.isiPhone4S ? "-4s" : ""))
		} else {
			//이미지가 있을 경우, 시간대가 바뀌는 경우 바꾸고 페이드
			if (currentBackgroundImage != getBackground(components.hour!)) {
				//시간대가 바뀌어야 하는 경우
				currentBackgroundImage = getBackground(components.hour!) //시간대 이미지 변경
				backgroundImageFadeView.alpha = 1
				if (UIDevice.current.userInterfaceIdiom == .phone) {
					backgroundImageView.image = UIImage( named:
						ThemeManager.getAssetPresets(themeGroup: .Background) + currentBackgroundImage + (
						DeviceManager.isiPhone4S ? ThemeManager.ThemePresets.iPhone4S : ""
						) )
				} else {
					backgroundImageView.image = UIImage( named:
						ThemeManager.getAssetPresets(themeGroup: .Background) + currentBackgroundImage + (
						(DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape
						) )
				} //end if [phone or not]
				
				UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
					self.backgroundImageFadeView.alpha = 0
					}, completion: {_ in
						if (UIDevice.current.userInterfaceIdiom == .phone) {
							self.backgroundImageFadeView.image = UIImage( named:
								ThemeManager.getAssetPresets(themeGroup: .Background) + self.currentBackgroundImage + (
								DeviceManager.isiPhone4S ? ThemeManager.ThemePresets.iPhone4S : ""
								) )
						} else {
							self.backgroundImageFadeView.image = UIImage( named:
								ThemeManager.getAssetPresets(themeGroup: .Background) + self.currentBackgroundImage + (
								(DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape
								) )
						} //end if [phone or not]
				}) //end animation block
			} //end if
		} //end if
		
		
		//Animate objects on Main
		for i:Int in 0 ..< mainAnimatedObjs.count {
			if (mainAnimatedObjs[i].target == nil) {
				continue
			} //ignore nil target
			mainAnimatedObjs[i].movY(2)
		} //end for
		
		
		//Guide 띄운 상태인 경우 특정 이미지 프레임 조정
		if (self.presentedViewController != nil) {
			if (self.presentedViewController == overlayGuideView) {
				overlayGuideView.guideGameFloatingImage.frame = GroundFloatingBox.frame
			} //end if [isPresentingView]
		} //end if [isPresenting]
		
    } //end tick func
	
	
	//get str from time
	func getBackground(_ timeHour:Int, isGround:Bool = false) -> String {
		if (timeHour >= 22 || timeHour < 6) {
			return isGround ? ThemeManager.ThemeFileNames.GroundNight : ThemeManager.ThemeFileNames.BackgroundNight
		} else if (timeHour >= 6 && timeHour < 11) {
			return isGround ? ThemeManager.ThemeFileNames.GroundMorning : ThemeManager.ThemeFileNames.BackgroundMorning
		} else if (timeHour >= 11 && timeHour < 18) {
			return isGround ? ThemeManager.ThemeFileNames.GroundDaytime : ThemeManager.ThemeFileNames.BackgroundDaytime
		} else if (timeHour >= 18 && timeHour <= 21) {
			return isGround ? ThemeManager.ThemeFileNames.GroundSunset : ThemeManager.ThemeFileNames.BackgroundSunset
		}
		return isGround ? ThemeManager.ThemeFileNames.GroundMorning : ThemeManager.ThemeFileNames.BackgroundMorning
	} //end func

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	/////////////////////////////////////////
	
	func checkToCallAlarmRingingView() -> Bool {
		//알람 뷰 콜을 체크하고, 불러와야 하면 표시함.
		//울린 후 안꺼진 알람이 있는지 체크한다.
		let ringingAlarm:AlarmElements? = AlarmManager.getRingingAlarm()
		if (ringingAlarm == nil) { //안꺼진 알람이 없음.
			return false
		} else { //알람이 울리고 있음
			print("Alarm is ringing")
			
			if (self.presentedViewController != nil) {
				if (self.presentedViewController! is AlarmRingView) {
					AlarmManager.alarmRingActivated = true
					print("Alarm ring progress is already running. skipping")
					
					return true
				}
			} //end if
			
			closeAllModalsForce()
			
			GlobalSubView.alarmRingViewcontroller.modalTransitionStyle = .crossDissolve
			self.present(GlobalSubView.alarmRingViewcontroller, animated: true, completion: nil)
			
			return true
		} //end check
		
		//return false
	} //end if
	
	//모든 modal 강제로 닫기 (바로 다음 뷰를 열때 사용)
	func closeAllModalsForce( ignoreBlurView:Bool = false ) {
		modalSettingsView.dismiss(animated: false, completion: nil)
		modalAlarmAddView.dismiss(animated: false, completion: nil)
		modalAlarmListView.dismiss(animated: false, completion: nil)
		modalAlarmStatsView.dismiss(animated: false, completion: nil)
		modalCharacterInformationView.dismiss(animated: false, completion: nil)
		modalPlayGameview.dismiss(animated: false, completion: nil)
		modalGameResultView.dismiss(animated: false, completion: nil)
		modalGamePlayWindowView.dismiss(animated: false, completion: nil)
		modalWebView.dismiss(animated: false, completion: nil)
		
		overlayGuideView.dismiss(animated: false, completion: nil)

		if (!ignoreBlurView) {
			self.showHideBlurview(false)
		} //end if
	} //// end func
	
	///////// 메인 스킨 변경 (혹은 스킨 설정 )
	func updateTheme() {
		///Update digital clock image cached
		digitalClockImageCached.removeAll()
		for i:Int in 0 ... 9 {
			digitalClockImageCached.append( UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + String(i) + ".png" )! )
		} //end for
		//// Make AMPM digital indicator
		digitalClockAMPMCached.removeAll()
		
		/// index 0 is am, 1 is pm
		digitalClockAMPMCached.append( UIImage(named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + ThemeManager.getName(ThemeManager.ThemeFileNames.DigitalClockAM))! )
		digitalClockAMPMCached.append( UIImage(named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + ThemeManager.getName(ThemeManager.ThemeFileNames.DigitalClockPM))! )
		///////////////
		
		///// Make clock image
		DigitalCol.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + ThemeManager.getName(ThemeManager.ThemeFileNames.DigitalClockCol) )
		
		////// Make analog-clock image
		AnalogBody.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.AnalogClockBody) )
		
		AnalogCenter.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.AnalogClockCenter) )
		AnalogHours.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.AnalogClockHour) )
		AnalogMinutes.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.AnalogClockMinute) )
		AnalogSeconds.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.AnalogClockSecond) )
		
		//떠있는 버튼
		SettingsImg.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.ObjectSettings) )
		AlarmListImg.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName(ThemeManager.ThemeFileNames.ObjectList) )
		
		GroundStatSign.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .StatsSign) + ThemeManager.getName(ThemeManager.ThemeFileNames.ObjectStatistics) )
		GroundStandingBox.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .GameIcon) + ThemeManager.getName(ThemeManager.ThemeFileNames.ObjectGameStanding) )
		GroundFloatingBox.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .GameIcon) + ThemeManager.getName(ThemeManager.ThemeFileNames.ObjectGameFloating) )
		
		//기본 스킨 아스트로 애니메이션 (텍스쳐)
		for i in 0...3 { //부동
			//Character는 번호 뒤에 확장자를 붙이므로 getname함수 사용안함
			let fileName:String = ThemeManager.getAssetPresets(themeGroup: .Character) + ThemeManager.ThemeFileNames.Character + "-" + String(i) + ".png"
			let fImage:UIImage = UIImage( named: fileName )!
			astroMotionsStanding += [fImage]
		} //end for
	} //end func
	
	//Element fit to screen 
	//주의: 패드와 폰 둘다 동작하게 일단 만들어 놔야함. 물론, 실제로 화면이 회전될 때는 패드에서만 작동함.
	//(단, init시 iPhone에서 작동함)
	func fitViewControllerElementsToScreen( _ animated:Bool = false ) {
		//DigitalCol
		var scrX:CGFloat = CGFloat(DeviceManager.scrSize!.width / 2 - ((40 * DeviceManager.maxScrRatioC) / 2))
		var digiClockYAxis:CGFloat = 90 * DeviceManager.scrRatioC
		scrX += 4 * DeviceManager.maxScrRatioC
		
		//가로로 누워있는 경우, 조정이 필요한 경우에 조금 조정
		if (UIDevice.current.userInterfaceIdiom == .phone) {
			//iPhone일 시, 4s이외의 경우 조금 더 위치를 내림
			if (DeviceManager.isiPhone4S == false) { //iPhone 4, 4s는 이 크기임
				//그래서 이 외의 경우임
				digiClockYAxis = 110 * DeviceManager.scrRatioC

			}
		} else { //iPad일 시 위치 조정
			if (UIDevice.current.orientation.isLandscape == true) {
				digiClockYAxis = 60 * DeviceManager.scrRatioC
			}
		} //end if
		
		let cForCalcuate:DateComponents = Calendar.current.dateComponents([ .hour, .minute, .second], from: Date())
		
		var hourString:String = ""
		var minString:String = ""
		
		if (DeviceManager.is24HourMode == true) {
			hourString = String(describing: cForCalcuate.hour!)
		} else {
			hourString = String(cForCalcuate.hour! > 12 ? cForCalcuate.hour! - 12 : (cForCalcuate.hour! == 0 ? 12 : cForCalcuate.hour)!)
		} //end if [is 24h or not]
		minString = String(describing: cForCalcuate.minute!)
		//fix string if length is 1
		hourString = hourString.characters.count == 1 ? "0" + hourString : hourString
		minString = minString.characters.count == 1 ? "0" + minString : minString
		
		let tNumMargin:CGFloat = 8 * DeviceManager.maxScrRatioC
		let dClockMinX:CGFloat = hourString[0] == "1" ? DigitalNum0.frame.minX + tNumMargin : DigitalNum0.frame.minX
		let dClockMaxX:CGFloat = minString[1] == "1" ? DigitalNum3.frame.maxX - tNumMargin : DigitalNum3.frame.maxX
		
		//디지털시계 이미지 스케일 조정
		digitalClockUIView.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - (dClockMaxX - dClockMinX) / 2, y: digiClockYAxis, width: (dClockMaxX - dClockMinX), height: 56 * DeviceManager.maxScrRatioC)
		DigitalCol.frame = CGRect(x: DigitalCol.frame.minX, y: 0, width: 40 * DeviceManager.maxScrRatioC, height: 56 * DeviceManager.maxScrRatioC)
		
		//x위치를 제외한 나머지 통일
		digitalAMPMIndicator.frame = CGRect(
			x: (DeviceManager.scrSize!.width / 2) - (28 * DeviceManager.maxScrRatioC / 2),
			y: digitalClockUIView.frame.minY - 31 * DeviceManager.maxScrRatioC,
			width: 28 * DeviceManager.maxScrRatioC, height: 14 * DeviceManager.maxScrRatioC)
		
		//UP 구매 버튼 위치 및 크기지정
		upExtPackButton.frame = CGRect( x: 18 * DeviceManager.maxScrRatioC, y: 34 * DeviceManager.maxScrRatioC,
		                                width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
		upLayerGuideShowButton.frame = CGRect( x: DeviceManager.scrSize!.width - ((50.5 + 18) * DeviceManager.maxScrRatioC), y: upExtPackButton.frame.minY, width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
		
		//시계 바디 및 시침 분침 위치/크기조절
		let clockScrX:CGFloat = CGFloat(DeviceManager.scrSize!.width / 2 - (CGFloat(300 * DeviceManager.maxScrRatioC) / 2))
		let clockRightScrX:CGFloat = CGFloat(DeviceManager.scrSize!.width / 2 + (CGFloat(300 * DeviceManager.maxScrRatioC) / 2))
		let clockScrY:CGFloat = CGFloat(DeviceManager.scrSize!.height / 2 - (CGFloat(300 * DeviceManager.maxScrRatio) / 2))
		//clockScrY += 10 * DeviceManager.maxScrRatioC;
		
		AnalogHours.transform = CGAffineTransform.identity
		AnalogMinutes.transform = CGAffineTransform.identity
		AnalogSeconds.transform = CGAffineTransform.identity

		AnalogBody.frame = CGRect( x: clockScrX, y: clockScrY, width: 300 * DeviceManager.maxScrRatioC, height: 300 * DeviceManager.maxScrRatioC )
		
		///////////////////
		//터치 에어리어를 위한 별도의 프레임
		touchAreaAnalogBody.frame =
			CGRect( x: DeviceManager.scrSize!.width / 2 - (CGFloat(168 * DeviceManager.maxScrRatioC) / 2),
			            y: CGFloat(DeviceManager.scrSize!.height / 2 - (CGFloat(200 * DeviceManager.maxScrRatio) / 2))
				+ 20 * DeviceManager.maxScrRatioC
				, width: 168 * DeviceManager.maxScrRatioC, height: 168 * DeviceManager.maxScrRatioC )
		
		//////////////////////
		
		AnalogHours.frame = CGRect( x: clockScrX, y: clockScrY, width: AnalogBody.frame.width, height: AnalogBody.frame.height )
		AnalogMinutes.frame = CGRect( x: clockScrX, y: clockScrY, width: AnalogBody.frame.width, height: AnalogBody.frame.height )
		AnalogSeconds.frame = CGRect( x: clockScrX, y: clockScrY, width: AnalogBody.frame.width, height: AnalogBody.frame.height )
		AnalogCenter.frame = CGRect( x: clockScrX, y: clockScrY, width: AnalogBody.frame.width, height: AnalogBody.frame.height )
		
		SettingsImg.frame = CGRect( x: clockScrX - ((240 * DeviceManager.maxScrRatioC) / 2), y: clockScrY + (72 * DeviceManager.maxScrRatioC) , width: (300 * DeviceManager.maxScrRatioC), height: (300 * DeviceManager.maxScrRatioC) )
		AlarmListImg.frame = CGRect( x: clockRightScrX - ((340 * DeviceManager.maxScrRatioC) / 2), y: clockScrY - (64 * DeviceManager.maxScrRatioC), width: (300 * DeviceManager.maxScrRatioC), height: (300 * DeviceManager.maxScrRatioC) )
		
		if (UIDevice.current.userInterfaceIdiom == .phone) {
			//배경화면 프레임도 같이 조절 (패드는 끝부분의 회전처리와 동시에 함)
			backgroundImageView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
			backgroundImageFadeView.frame = backgroundImageView.frame
			
			//땅 크기 조절
			GroundObj.frame = CGRect( x: 0, y: DeviceManager.scrSize!.height - 86 * DeviceManager.maxScrRatioC, width: CGFloat((DeviceManager.scrSize?.width)!) , height: 86 * DeviceManager.maxScrRatioC )
		} else { //패드에서의 땅 크기 조절
			//show pad ground
			GroundObj.frame = CGRect( x: 0, y: DeviceManager.scrSize!.height - 86 * DeviceManager.maxScrRatioC, width: (DeviceManager.scrSize!.width) , height: 86 * DeviceManager.maxScrRatioC )
			GroundObj.image = UIImage( named:
				ThemeManager.getAssetPresets(themeGroup: .Main, themeID: ThemeManager.legacyDefaultTheme) + currentGroundImage + ThemeManager.getName((DeviceManager.scrSize!.width > DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadLandscape : ThemeManager.ThemePresets.PadPortrait) )
		} //end if [isPhone]
		
		//캐릭터 크기 및 위치조정
		AstroCharacter.frame =
			CGRect( x: DeviceManager.scrSize!.width - (220 * DeviceManager.maxScrRatioC),
			            y: GroundObj.frame.origin.y - (178 * DeviceManager.maxScrRatioC),
			            width: 300 * DeviceManager.maxScrRatioC,
			            height: 300 * DeviceManager.maxScrRatioC )
		GroundStatSign.frame =
			CGRect( x: -52 * DeviceManager.maxScrRatioC,
			            y: GroundObj.frame.origin.y - (185 * DeviceManager.maxScrRatioC),
			            width: 300 * DeviceManager.maxScrRatioC,
			            height: 300 * DeviceManager.maxScrRatioC )
		GroundStandingBox.frame =
			CGRect( x: AstroCharacter.frame.midX - (240 * DeviceManager.maxScrRatioC),
			            y: GroundObj.frame.origin.y - (144 * DeviceManager.maxScrRatioC),
			            width: 300 * DeviceManager.maxScrRatioC,
			            height: 300 * DeviceManager.maxScrRatioC )
		GroundFloatingBox.frame =
			CGRect( x: GroundStandingBox.frame.minX,
			            y: GroundStandingBox.frame.origin.y - (38 * DeviceManager.maxScrRatioC),
			            width: 300 * DeviceManager.maxScrRatioC,
			            height: 300 * DeviceManager.maxScrRatioC )
		////////////////////
		
		touchAreaStatistics.frame = CGRect( x: 0, y: GroundObj.frame.minY - (92 * DeviceManager.maxScrRatioC), width: 180 * DeviceManager.maxScrRatioC, height: 160 * DeviceManager.maxScrRatioC  )
		
		//터치용 투명박스 조정
		touchAreaPlayGame.frame =
			CGRect(
				x: GroundStandingBox.frame.midX - (62 * DeviceManager.maxScrRatioC),
				y: GroundStandingBox.frame.midY - (132 * DeviceManager.maxScrRatioC),
				width: 100 * DeviceManager.maxScrRatioC, height: 160 * DeviceManager.maxScrRatioC )
		
		///////////////////////////
		//Guide 띄운 상태인 경우 특정 이미지 프레임 조정
		if (self.presentedViewController != nil) {
			if (self.presentedViewController == overlayGuideView) {
				overlayGuideView.guideGameFloatingImage.frame = GroundFloatingBox.frame
			} //end if [isPresentingView]
		} //end if [isPresenting]
		
		//Modal view 크기 가운데로 조정. (rotation)
		modalSettingsView.FitModalLocationToCenter( )
		modalAlarmListView.FitModalLocationToCenter( )
		modalAlarmAddView.FitModalLocationToCenter( )
		modalAlarmStatsView.FitModalLocationToCenter( )
		modalCharacterInformationView.FitModalLocationToCenter( )
		modalPlayGameview.FitModalLocationToCenter( )
		modalGameResultView.FitModalLocationToCenter( )
		modalGamePlayWindowView.FitModalLocationToCenter( )
		modalWebView.FitModalLocationToCenter( )
		modalBuyExPackView.FitModalLocationToCenter()
		
		overlayGuideView.fitFrames()
		
		//Blur view 조절
		scrBlurView.frame = DeviceManager.scrSize!
		
		//안내 텍스트 조절
		upAlarmMessageText.textAlignment = .center
		upAlarmMessageView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: 48)
		upAlarmMessageText.frame = CGRect(x: 0, y: 12, width: DeviceManager.scrSize!.width, height: 24)
		
		//애니메이션되는 항목의 경우 프레임 위치를 리셋하기 때문에 마찬가지로 이동항목도 리셋
		for i:Int in 0 ..< mainAnimatedObjs.count {
			mainAnimatedObjs[i].movCurrentFactor = 0
			mainAnimatedObjs[i].movReverse = false
		} //end for
		
		//버그로 인해 위치변경 전까진 transform이 없어야 함
		let date = Date()
		let calendar = Calendar.current
		let components = (calendar as NSCalendar).components([ .hour, .minute, .second], from: date)
		let secondmov:Double = Double(components.minute!) / 60 / 12
		AnalogHours.transform = CGAffineTransform(rotationAngle: CGFloat(((Double(components.hour!) / 12) + secondmov) * 360) * CGFloat(M_PI) / 180 )
		AnalogMinutes.transform = CGAffineTransform(rotationAngle: CGFloat((Double(components.minute!) / 60) * 360) * CGFloat(M_PI) / 180 )
		AnalogSeconds.transform = CGAffineTransform(rotationAngle: CGFloat((Double(components.second!) / 60) * 360) * CGFloat(M_PI) / 180 )
		
		//시간대의 변경은 아니지만, 배경의 배율에 따라서 달라지는 부분이 있으므로 변경
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			//배경의 자연스러운 변경 연출을 위한 애니메이션 효과 적용
			currentBackgroundImage = getBackground(components.hour!)
			backgroundImageFadeView.image = backgroundImageView.image
			backgroundImageView.image = UIImage( named: ThemeManager.ThemePresets.BundlePreset + currentBackgroundImage + ThemeManager.getName(
				(DeviceManager.scrSize!.width < DeviceManager.scrSize!.height) ? ThemeManager.ThemePresets.PadPortrait : ThemeManager.ThemePresets.PadLandscape
				))
			backgroundImageFadeView.alpha = 1
			backgroundImageView.alpha = 0
			
			//Background image scale
			backgroundImageView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
			
			UIView.animate(withDuration: 0.48, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
				self.backgroundImageFadeView.alpha = 0
				self.backgroundImageView.alpha = 1
				}, completion: {_ in
					self.backgroundImageFadeView.frame = self.backgroundImageView.frame
			}) ///end animation block
		} //end if
	} //end func
	
	
	//iOS 8.0 Rotation
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		print("View transition running. . .")
		//Re-calcuate scrSize
		DeviceManager.changeDeviceSizeWith(size)
		//Fit elements again
		fitViewControllerElementsToScreen( true )
		//Fit views to startguide
		GlobalSubView.startingGuideView.fitView( size )
	}
	
	////////////////////////////
	//notify on scr
	func showMessageOnView( _ message:String, backgroundColorHex:String, textColorHex:String ) {
		if (upAlarmMessageView.isHidden == false) {
			//몇초 뒤 나타나게 함.
			_ = UPUtils.setTimeout(2.5, block: {_ in
				self.showMessageOnView( message, backgroundColorHex: backgroundColorHex, textColorHex: textColorHex )
				})
			return
		}
		
		self.view.bringSubview(toFront: upAlarmMessageView)
		upAlarmMessageView.isHidden = false
		upAlarmMessageView.backgroundColor = UPUtils.colorWithHexString(backgroundColorHex)
		upAlarmMessageText.textColor = UPUtils.colorWithHexString(textColorHex)
		upAlarmMessageText.text = message
		
		UIApplication.shared.setStatusBarHidden(true, with: .fade) //statusbar hidden
		self.upAlarmMessageView.frame = CGRect(x: 0, y: -self.upAlarmMessageView.frame.height, width: self.upAlarmMessageView.frame.width, height: self.upAlarmMessageView.frame.height)
		
		//Message animation
		UIView.animate(withDuration: 0.32, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upAlarmMessageView.frame = CGRect(x: 0, y: 0, width: self.upAlarmMessageView.frame.width, height: self.upAlarmMessageView.frame.height)
			}, completion: {_ in
		})
		//animation fin.
		UIView.animate(withDuration: 0.32, delay: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.upAlarmMessageView.frame = CGRect(x: 0, y: -self.upAlarmMessageView.frame.height, width: self.upAlarmMessageView.frame.width, height: self.upAlarmMessageView.frame.height)
			}, completion: {_ in
				self.upAlarmMessageView.isHidden = true
				UIApplication.shared.setStatusBarHidden(false, with: .fade)
		})
	} //end func
	
	//////
	
	func runGame() {
		//게임 시작
		print("ViewController: rungame started")
		closeAllModalsForce() //closes all modal force
		
		GameModeView.isGameExiting = false
		GlobalSubView.gameModePlayViewcontroller.modalTransitionStyle = .crossDissolve
		self.present(GlobalSubView.gameModePlayViewcontroller, animated: true, completion: nil)
	}
	
	/////////// 게임 결과 호출 창
	func showGameResult( _ gameID:Int, type:Int, score:Int, best:Int ) {
		//Score 및 best는 보여주기용이며, 저장은 각 게임 혹은 이 함수 호출 전에 알아서.
		//Type 0: alarm, 1: game
		modalGameResultView.setVariables(gameID, windowType: type, showingScore: score, showingBest: best)
		
		showHideBlurview(true)
		modalGameResultView.modalPresentationStyle = .overFullScreen
		self.present(modalGameResultView, animated: false, completion: nil)
	}
	
	///// 공지사항 띄움
	func callShowNoticeModal() {
		if (isNoticeCalled) {
			return
		}
		isNoticeCalled = true
		showWebViewModal( url: "https://up.avngraphic.kr/inapp/testers/?l=" + LanguagesManager.currentLocaleCode )
	}
	func showWebViewModal( url:String ) {
		if (self.presentingViewController == modalWebView) {
			modalWebView.openURL( url )
			return
		} //end if
		//Modal 실행 시 다음부터는 notice 띄우지 않도록 함
		//(링크 있는 푸시로 처음 킨 경우 문제가 발생하기 때문)
		isNoticeCalled = true
		
		closeAllModalsForce( ignoreBlurView: true )
		
		modalWebView.openURL( url )
		
		showHideBlurview(true)
		modalWebView.modalPresentationStyle = .overFullScreen
		self.present(modalWebView, animated: false, completion: nil)
	} //end func
	
	func showGuideView( _ gst: UITapGestureRecognizer? ) {
		//가이드 뷰를 (다시) 보여줌. blurview 사용안함
		
		overlayGuideView.modalPresentationStyle = .overFullScreen
		self.present(overlayGuideView, animated: true, completion: nil)
	} //end func
	
	func updatePurchaseStates() {
		//Purchase 상태에 따라 메인 화면의 element 숨김/표시여부 결정.
		if (PurchaseManager.purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] == true) {
			//구매하였으니 버튼 비표시
			upExtPackButton.isHidden = true
		} else {
			//구매 버튼 표시
			upExtPackButton.isHidden = false
		} //end if
	} //end func
	
} //end class


extension String {
	subscript(i: Int) -> String {
		guard i >= 0 && i < characters.count else { return "" }
		return String(self[index(startIndex, offsetBy: i)])
	}
	subscript(range: Range<Int>) -> String {
		let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
		return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
	}
	subscript(range: ClosedRange<Int>) -> String {
		let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
		return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
	}
}

