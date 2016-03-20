//
//  ViewController.swift
//  UP
//
//  Created by ExFl on 2016. 1. 20..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import UIKit;
import AVFoundation;
import AudioToolbox;

class ViewController: UIViewController {

	/// 스토리보드 리소스를 옮겨야함 (스킨때문에)
	
	//Digital 시계
	var DigitalNum0:UIImageView = UIImageView(); var DigitalNum1:UIImageView = UIImageView();
	var DigitalNum2:UIImageView = UIImageView(); var DigitalNum3:UIImageView = UIImageView();
	var DigitalCol:UIImageView = UIImageView();
	//아날로그 시계
	var AnalogBody:UIImageView = UIImageView(); var AnalogHours:UIImageView = UIImageView();
	var AnalogMinutes:UIImageView = UIImageView(); var AnalogBodyBack:UIImageView = UIImageView();
	//아날로그 시계 좌우 버튼
	var SettingsImg:UIImageView = UIImageView(); var AlarmListImg:UIImageView = UIImageView();
	//땅 부분
	var GroundObj:UIImageView = UIImageView(); var AstroCharacter:UIImageView = UIImageView();
	
	///아래 애니메이션 이미지의 이미지 배열도 스킨에 따라 바뀜.
	//스탠딩 모션
    var astroMotionsStanding:Array<UIImage> = [];
	//달리기
    var astroMotionsRunning:Array<UIImage> = [];
	//점프
    var astroMotionsJumping:Array<UIImage> = [];
	
	
    //Modal views
    var modalSettingsView:SettingsView = SettingsView();
    var modalAlarmListView:AlarmListView = AlarmListView();
	var modalAlarmAddView:AddAlarmView = GlobalSubView.alarmAddView;
	
	//screen blur view
	var scrBlurView:AnyObject?;
	
	static var viewSelf:ViewController?;
	internal var viewImage:UIImage = UIImage();
	
	//////////
	//뒷 배경 이미지 (시간에 따라 변경되며 변경 시간대마다 한번씩 fade)
	var backgroundImageView:UIImageView = UIImageView();
	var backgroundImageFadeView:UIImageView = UIImageView();
	var currentBackgroundImage:String = "a";
	
    //viewdidload - inital 함수. 뷰 로드시 자동실행
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //Init device size factor
        DeviceGeneral.initialDeviceSize();
		
		//Background image add
		backgroundImageView.frame = CGRectMake(0, 0, (DeviceGeneral.scrSize?.width)!, (DeviceGeneral.scrSize?.height)!);
		backgroundImageFadeView.frame = backgroundImageView.frame;
		self.view.addSubview(backgroundImageView); self.view.addSubview(backgroundImageFadeView);
		self.view.sendSubviewToBack(backgroundImageFadeView); self.view.sendSubviewToBack(backgroundImageView);
		
		//리소스 뷰에 추가
		self.view.addSubview(DigitalNum0); self.view.addSubview(DigitalNum1); self.view.addSubview(DigitalNum2); self.view.addSubview(DigitalNum3);
		self.view.addSubview(DigitalCol);
		
		self.view.addSubview(AnalogBody); self.view.addSubview(AnalogHours); self.view.addSubview(AnalogMinutes); self.view.addSubview(AnalogBodyBack);
		self.view.addSubview(SettingsImg); self.view.addSubview(AlarmListImg);
		self.view.addSubview(GroundObj); self.view.addSubview(AstroCharacter);
		
		//리소스 우선순위 설정
		self.view.bringSubviewToFront(DigitalCol);
		self.view.bringSubviewToFront(DigitalNum0); self.view.bringSubviewToFront(DigitalNum1);
		self.view.bringSubviewToFront(DigitalNum2); self.view.bringSubviewToFront(DigitalNum3);
		
		self.view.bringSubviewToFront(AnalogBodyBack); self.view.bringSubviewToFront(AnalogBody);
		self.view.bringSubviewToFront(AnalogHours); self.view.bringSubviewToFront(AnalogMinutes);
		
		self.view.bringSubviewToFront(GroundObj); self.view.bringSubviewToFront(AstroCharacter);
		
		//디지털시계 이미지 기본 설정
		DigitalCol.image = UIImage( named: "col.png" );
		DigitalNum0.image = UIImage( named: "0.png" ); DigitalNum1.image = UIImage( named: "0.png" );
		DigitalNum2.image = UIImage( named: "0.png" ); DigitalNum3.image = UIImage( named: "0.png" );
		DigitalCol.frame.size = CGSizeMake( 43.5, 60.9 ); //디바이스별 크기 설정은 밑에서 하므로 여긴 원본 크기를 입력함.
		
		//기본 스킨 선택. 나중엔 저장된 스킨번호를 불러오게 변경.
		selectMainSkin(0);
		
        var scrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 - (DigitalCol.bounds.width / 2));
        scrX += 4 * DeviceGeneral.maxScrRatioC;
		
		  //디지털시계 이미지 스케일 조정
        DigitalCol.frame = CGRectMake(scrX, 90 * DeviceGeneral.scrRatioC, DigitalCol.bounds.width * DeviceGeneral.maxScrRatioC, DigitalCol.bounds.height * DeviceGeneral.maxScrRatioC);
		
        //x위치를 제외한 나머지 통일
        DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width * 2 - 20 * DeviceGeneral.maxScrRatioC, DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - 12 * DeviceGeneral.maxScrRatioC, DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + 20 * DeviceGeneral.maxScrRatioC, DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + 12 * DeviceGeneral.maxScrRatioC, DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        
		
        //시계 바디 및 시침 분침 위치/크기조절
        let clockScrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 - (CGFloat(245 * DeviceGeneral.maxScrRatioC) / 2));
        let clockRightScrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 + (CGFloat(245 * DeviceGeneral.maxScrRatioC) / 2));

        //clockScrX += CGFloat(4 * DeviceGeneral.maxScrRatio);
        var clockScrY:CGFloat = CGFloat((DeviceGeneral.scrSize?.height)! / 2 - (CGFloat(245 * DeviceGeneral.maxScrRatio) / 2));
        clockScrY += 20 * DeviceGeneral.maxScrRatioC;
        
        AnalogBody.frame = CGRectMake( clockScrX, clockScrY, 245 * DeviceGeneral.maxScrRatioC, 245 * DeviceGeneral.maxScrRatioC );
        AnalogHours.frame = CGRectMake( clockScrX, clockScrY, 245 * DeviceGeneral.maxScrRatioC, 245 * DeviceGeneral.maxScrRatioC );
        AnalogMinutes.frame = CGRectMake( clockScrX, clockScrY, 245 * DeviceGeneral.maxScrRatioC, 245 * DeviceGeneral.maxScrRatioC );
        
        AnalogBodyBack.frame = CGRectMake( clockScrX - (18 * DeviceGeneral.maxScrRatioC), clockScrY - (10 * DeviceGeneral.maxScrRatioC), (273 * DeviceGeneral.maxScrRatioC), (255 * DeviceGeneral.maxScrRatioC) );
        SettingsImg.frame = CGRectMake( clockScrX - ((135 * DeviceGeneral.maxScrRatioC) / 2), clockScrY + (125 * DeviceGeneral.maxScrRatioC) , (157 * DeviceGeneral.maxScrRatioC), (157 * DeviceGeneral.maxScrRatioC) );
        AlarmListImg.frame = CGRectMake( clockRightScrX - ((90 * DeviceGeneral.maxScrRatioC) / 2), clockScrY - (10 * DeviceGeneral.maxScrRatioC), (105 * DeviceGeneral.maxScrRatioC), (150 * DeviceGeneral.maxScrRatioC) );
		
		//기본 스킨이 선택된 상태에서
        AstroCharacter.animationImages = astroMotionsStanding;
        AstroCharacter.animationDuration = 1.0; AstroCharacter.animationRepeatCount = -1;
        AstroCharacter.startAnimating();
        
        //Modal view 크기 및 위치
        modalSettingsView.setupModalView( getGeneralModalRect() );
		modalAlarmListView.setupModalView( getGeneralModalRect() );
		modalAlarmAddView.setupModalView( getGeneralModalRect() );
		
        //시계 이미지 터치시
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("openAlarmaddView:")); //openAlarmaddView
        AnalogMinutes.userInteractionEnabled = true;
        AnalogMinutes.addGestureRecognizer(tapGestureRecognizer);
        
        //환경설정 아이콘 터치시
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("openSettingsView:"))
        SettingsImg.userInteractionEnabled = true;
        SettingsImg.addGestureRecognizer(tapGestureRecognizer);
        
        //리스트 아이콘 터치시
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("openAlarmlistView:"))
        AlarmListImg.userInteractionEnabled = true;
        AlarmListImg.addGestureRecognizer(tapGestureRecognizer);
		
		//클래스 외부접근을 위함
		ViewController.viewSelf = self;
        
        //Startup permission request
        if #available(iOS 8.0, *) {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
			UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings);
			
			//iOS8 blur effect
//			self.view.bounds
			let scBlurEffect:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light));
			scBlurEffect.frame = self.view.bounds;
			scBlurEffect.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
			scBlurEffect.translatesAutoresizingMaskIntoConstraints = true;
			scrBlurView = scBlurEffect;
			
        } else {
            // Fallback on earlier versions
        };
		
		//FOR TEST
		//UIApplication.sharedApplication().cancelAllLocalNotifications();
		//AlarmManager.clearAlarm();
		
		updateTimeAnimation(); //first call
		setInterval(0.5, block: updateTimeAnimation);
		
		
		//Background thread start
		//backgroundThreadNSTimer = NSTimer(timeInterval: 2.0, target: self, selector: "upAlarmBackgroundThread:", userInfo: nil, repeats: true);
		//NSRunLoop.currentRunLoop().addTimer( backgroundThreadNSTimer!, forMode: NSRunLoopCommonModes );
		
		//무음모드 사운드 허용
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
			print("AVAudioSession Category Playback OK")
			do {
				try AVAudioSession.sharedInstance().setActive(true)
				print("AVAudioSession is Active")
			} catch let error as NSError {
				print(error.localizedDescription)
			}
		} catch let error as NSError {
			print(error.localizedDescription)
		}
		
		
    }
	
	override func viewDidAppear(animated: Bool) {
		//Check alarms
		checkToCallAlarmRingingView();
	}
	
	func showHideBlurview( show:Bool ) {
		if #available(iOS 8.0, *) {
			if (show) {
				self.view.addSubview(scrBlurView as! UIVisualEffectView);
				(scrBlurView as! UIVisualEffectView).alpha = 0;
				UIView.animateWithDuration(0.32, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
					(self.scrBlurView as! UIVisualEffectView).alpha = 1;
				}, completion: nil);
			} else {
				(scrBlurView as! UIVisualEffectView).alpha = 1;
				UIView.animateWithDuration(0.32, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
				(self.scrBlurView as! UIVisualEffectView).alpha = 0;
					}, completion: {_ in
						self.scrBlurView?.removeFromSuperview();
				});
			}
		} else {
			//iOS 7 fallback
			if (show == true) {
				UIGraphicsBeginImageContext(view.frame.size);
				view.layer.renderInContext(UIGraphicsGetCurrentContext()!);
				viewImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
			}
		}
	}
	
	//modal cgrect
	func getGeneralModalRect() -> CGRect {
		
		return CGRectMake(DeviceGeneral.defaultModalSizeRect.minX , DeviceGeneral.defaultModalSizeRect.minY , DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
	}
	
	func openAlarmaddView (gestureRecognizer: UITapGestureRecognizer) {
		//알람추가뷰 열기
		modalAlarmAddView.showBlur = true;
		
		if #available(iOS 8.0, *) {
			modalAlarmAddView.modalPresentationStyle = .OverFullScreen;
		} else {
			modalAlarmAddView.removeBackgroundViews();
		}
		showHideBlurview(true);
		self.presentViewController(modalAlarmAddView, animated: true, completion: nil);
		modalAlarmAddView.clearComponents();
		
	}
	
    func openSettingsView (gestureRecognizer: UITapGestureRecognizer) {
        //환경설정 열기
        if #available(iOS 8.0, *) {
			modalSettingsView.modalPresentationStyle = .OverFullScreen;
		}
		showHideBlurview(true);
        self.presentViewController(modalSettingsView, animated: true, completion: nil);
		modalSettingsView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
    }
    func openAlarmlistView (gestureRecognizer: UITapGestureRecognizer) {
        //Alarmlist view 열기
        if #available(iOS 8.0, *) {
			modalAlarmListView.modalPresentationStyle = .OverFullScreen;
        }
		showHideBlurview(true);
		
        self.presentViewController(modalAlarmListView, animated: true, completion: nil);
		modalAlarmListView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
    }
	
	
	//아래는 테스트 func이며 삭제 예정
    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        //이동할 뷰 컨트롤러 인스턴스 생성
        let uvc = self.storyboard?.instantiateViewControllerWithIdentifier("testGameViewID")
        //화면 전환 스타일 설정
        uvc?.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        //화면 전환
		self.presentViewController(uvc!, animated: true, completion: nil);
    }
    
  
    func updateTimeAnimation() {
        //setinterval call
        
        //get time and calcuate
        let date = NSDate(); let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date);
        
        let hourString:String = String(components.hour);
        let minString:String = String(components.minute);
		
		//hour str time
        if (hourString.characters.count) == 1 {
            DigitalNum0.image = UIImage( named: "0.png" );
            DigitalNum1.image = UIImage( named:  hourString[0] + ".png" );
            
            if (hourString[0] == "1") {
                //숫자1의경우 오른쪽으로 당김.
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - (14 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - (6 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            } else {
                //원래 위치로
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - (20 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - (12 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            }
            
        } else { //첫자리 밑 둘째자리는 각 시간에 맞게
            DigitalNum0.image = UIImage( named:  hourString[0] + ".png" );
            DigitalNum1.image = UIImage( named:  hourString[1] + ".png" );
            
            var movesRightOffset:Double = 0;
             if (hourString[0] == "1") {
                //오른쪽으로 당김
                movesRightOffset += 6;
            }
			
            if (hourString[1] == "1") {
                //가능한 경우 최대 두번 당김
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat(((8 - movesRightOffset) - movesRightOffset) * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                movesRightOffset += 6;
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat((14 - movesRightOffset) * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            } else {
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat((20 - movesRightOffset) * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - (12 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            }
        } //end of hour str
		
		//min str
        if (minString.characters.count == 1) {
            DigitalNum2.image = UIImage( named: "0.png" );
            DigitalNum3.image = UIImage( named:  minString[0] + ".png" );
            
            if (minString[0] == "1") {
                //숫자1의경우 왼쪽으로 당김.
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + (14 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + (12 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);

            } else {
                //원래 위치로
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + (20 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + (12 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);

            }
            
        } else { //첫자리 밑 둘째자리는 각 시간에 맞게
            DigitalNum2.image = UIImage( named:  minString[0] + ".png" );
            DigitalNum3.image = UIImage( named:  minString[1] + ".png" );
            
            var movesLeftOffset:Double = 0;
            if (minString[1] == "1") {
                //가능한 경우 최대 두번 당김
                movesLeftOffset += 6;
            }
            
            if (minString[0] == "1") {
                //왼쪽으로 당김
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + (6 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                movesLeftOffset += 6;
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat((14 - movesLeftOffset) * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                
            } else {
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + (12 * DeviceGeneral.maxScrRatioC), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat((20 - movesLeftOffset) * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            }
            
        } //end of min str
		
		//col animation
        if (!DigitalCol.hidden) {
            //1초주기 실행
            let secondmov:Double = Double(components.minute) / 60 / 12;
            AnalogHours.transform = CGAffineTransformMakeRotation(CGFloat(((Double(components.hour) / 12) + secondmov) * 360) * CGFloat(M_PI) / 180 );
            AnalogMinutes.transform = CGAffineTransformMakeRotation(CGFloat((Double(components.minute) / 60) * 360) * CGFloat(M_PI) / 180 );
			
        }
        DigitalCol.hidden = !DigitalCol.hidden;
		
		/*backgroundImageView backgroundImageFadeView currentBackgroundImage*/
		
		if (backgroundImageView.image == nil) {
			//이미지가 없을 경우 새로 표시.
			currentBackgroundImage = getBackgroundFileNameFromTime(components.hour);
			print("current", UIApplication.sharedApplication().statusBarOrientation == .Portrait);
			if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
				print("showing phone bg");
				backgroundImageView.image = UIImage( named: currentBackgroundImage + "_back" + (
					DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
					) );
				backgroundImageFadeView.image = UIImage( named: currentBackgroundImage + "_back" + (
					DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
					) );
			} else {
				print("showing pad bg");
				backgroundImageView.image = UIImage( named: currentBackgroundImage + "_back" + (
					(UIApplication.sharedApplication().statusBarOrientation == .Portrait || UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown) ? "_pad43" : ""
					) );
				backgroundImageFadeView.image = UIImage( named: currentBackgroundImage + "_back" + (
					(UIApplication.sharedApplication().statusBarOrientation == .Portrait || UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown) ? "_pad43" : ""
					) );
			}
			
			backgroundImageFadeView.alpha = 0;
			print("Scrsize",DeviceGeneral.scrSize?.height, (DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""));
		} else {
			//이미지가 있을 경우, 시간대가 바뀌는 경우 바꾸고 페이드
			if (currentBackgroundImage != getBackgroundFileNameFromTime(components.hour)) {
				//시간대가 바뀌어야 하는 경우
				currentBackgroundImage = getBackgroundFileNameFromTime(components.hour); //시간대 이미지 변경
				backgroundImageFadeView.alpha = 1;
				
				if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
					print("changing to phone bg");
					backgroundImageView.image = UIImage( named: currentBackgroundImage + "_back" + (
						DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
						) );
				} else {
					print("changing to pad bg");
					backgroundImageView.image = UIImage( named: currentBackgroundImage + "_back" + (
						(UIApplication.sharedApplication().statusBarOrientation == .Portrait || UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown) ? "_pad43" : ""
						) );
				}
				
				UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
					self.backgroundImageFadeView.alpha = 0;
					}, completion: {_ in
						
						if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
							print("changed to phone bg");
							self.backgroundImageFadeView.image = UIImage( named: self.currentBackgroundImage + "_back" + (
								DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
								) );
						} else {
							print("changed to pad bg");
							self.backgroundImageFadeView.image = UIImage( named: self.currentBackgroundImage + "_back" + (
								(UIApplication.sharedApplication().statusBarOrientation == .Portrait || UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown) ? "_pad43" : ""
								) );
						}
						
				});
				
				
			} //end if
		} //end if
		
		
    } //end tick func
	
	
	//get str from time
	func getBackgroundFileNameFromTime(timeHour:Int)->String {
		if (timeHour >= 0 && timeHour < 6) {
			return "d";
		} else if (timeHour >= 6 && timeHour < 12) {
			return "a";
		} else if (timeHour >= 12 && timeHour < 18) {
			return "b";
		} else if (timeHour >= 18 && timeHour <= 23) {
			return "c";
		}
		return "a";
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: false)
    }
    
    func setInterval(interval:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(interval, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: true)
    }
	
	/////////////////////////////////////////
	
	internal func checkToCallAlarmRingingView() {
		//알람 뷰 콜을 체크하고, 불러와야 하면 표시함.
		//울린 후 안꺼진 알람이 있는지 체크한다.
		let ringingAlarm:AlarmElements? = AlarmManager.getRingingAlarm();
		if (ringingAlarm == nil) {
			//안꺼진 알람이 없음.
			
		} else {
			//알람이 울리고 있음
			print("Alarm is ringing");
			
			//dismiss current views
			/*if (self.presentingViewController != nil) {
				print("Dismissing actived view");
				if (self.presentingViewController == modalSettingsView) {
					modalSettingsView.dismissViewControllerAnimated(false, completion: nil);
				}
				if (self.presentingViewController == modalAlarmAddView) {
					modalAlarmAddView.dismissViewControllerAnimated(false, completion: nil);
				}
				if (self.presentingViewController == modalAlarmListView) {
					modalAlarmListView.dismissViewControllerAnimated(false, completion: nil);
				}
			}*/
			
			if (AlarmManager.alarmRingActivated == true) {
				print("Alarm ring progress is already running. skipping");
			} else {
				modalSettingsView.dismissViewControllerAnimated(false, completion: nil);
				modalAlarmAddView.dismissViewControllerAnimated(false, completion: nil);
				modalAlarmListView.dismissViewControllerAnimated(false, completion: nil);
				//Dismiss하면서 blur같은거 없애야 하는데, 일단 지금은 그게 뜨는지 체크먼저 해보고 구현 예정 ....
				self.showHideBlurview(false); 
				self.presentViewController(GlobalSubView.alarmRingViewcontroller, animated: true, completion: nil);
				AlarmManager.alarmRingActivated = true;
				
			} //end check is running
			
		} //end check
		
	} //end if
	
	///////// 메인 스킨 변경 (혹은 스킨 설정 )
	func selectMainSkin(skinID:Int = 0) {
		
		switch(skinID) {
			case 0: //기본 up 스킨
				
				//시계
				AnalogBody.image = UIImage( named: "time_body.png" ); AnalogHours.image = UIImage( named: "time_hh.png" );
				AnalogMinutes.image = UIImage( named: "time_mh.png" ); AnalogBodyBack.image = UIImage( named: "time_body_back.png" );
				//떠있는 버튼
				SettingsImg.image = UIImage( named: "object_st.png" ); AlarmListImg.image = UIImage( named: "object_list.png" );
				//땅 부분 (아스트로는 위에서 지정함) iPad의 경우 이미지를 넓은 것으로 교체할 필요가 있음
				if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
					GroundObj.image = UIImage( named: "ground.png" );
					GroundObj.frame = CGRectMake( 0, (DeviceGeneral.scrSize?.height)! - 75 * DeviceGeneral.maxScrRatioC, CGFloat((DeviceGeneral.scrSize?.width)!) , 75 * DeviceGeneral.maxScrRatioC );
				} else {
					//show pad ground
					GroundObj.image = UIImage( named: "ground_pad43.png" );
					GroundObj.frame = CGRectMake( 0, (DeviceGeneral.scrSize?.height)! - 75 * DeviceGeneral.maxScrRatioC, (DeviceGeneral.scrSize!.width) , 85.6 * DeviceGeneral.maxScrRatioC );
				}
				
				
				//Astro 크기 및 위치조정
				AstroCharacter.frame = CGRectMake( (DeviceGeneral.scrSize?.width)! - (126 * DeviceGeneral.maxScrRatioC), GroundObj.frame.origin.y - (151 * DeviceGeneral.maxScrRatioC) + (9 * DeviceGeneral.maxScrRatioC), 60 * DeviceGeneral.maxScrRatioC, 151 * DeviceGeneral.maxScrRatioC );
				
				//기본 스킨 아스트로 애니메이션 (텍스쳐)
				for i in 1...40 { //부동
					let numberStr:String = String(i).characters.count == 1 ? "0" + String(i) : String(i);
					let fileName:String = "astro" + "00" + numberStr + ".png";
					let fImage:UIImage = UIImage( named: fileName )!;
					astroMotionsStanding += [fImage];
				} /* 아직 안쓰니까 주석처리함. 쓸때 다시 주석 품,
				for i in 161...190 { //달리기(걷기)
				let numberStr:String = String(i);
				let fileName:String = "astro" + "0" + numberStr + ".png";
				let fImage:UIImage = UIImage( named: fileName )!;
				astroMotionsRunning += [fImage];
				}
				for i in 221...264 { //점프밎착지
				let numberStr:String = String(i);
				let fileName:String = "astro" + "0" + numberStr + ".png";
				let fImage:UIImage = UIImage( named: fileName )!;
				astroMotionsJumping += [fImage];
				} */

				
				break;
			default: break;
		}
		
	}
	
	
    ///////////
	
    //Changes image size
	
    func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
	
}


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
}


