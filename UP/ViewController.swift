//
//  ViewController.swift
//  UP
//
//  Created by ExFl on 2016. 1. 20..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var DigitalNum0: UIImageView!
    @IBOutlet weak var DigitalCol: UIImageView!
    @IBOutlet weak var DigitalNum1: UIImageView!
    @IBOutlet weak var DigitalNum2: UIImageView!
    @IBOutlet weak var DigitalNum3: UIImageView!
    
    @IBOutlet weak var GroundObj: UIImageView!
    @IBOutlet weak var AnalogBody: UIImageView!
    @IBOutlet weak var AnalogHours: UIImageView!
    @IBOutlet weak var AnalogMinutes: UIImageView!
    
    @IBOutlet weak var AnalogBodyBack: UIImageView!
    @IBOutlet weak var SettingsImg: UIImageView!
    @IBOutlet weak var AlarmListImg: UIImageView!
    
    @IBOutlet weak var AstroCharacter: UIImageView!
	
	////////// 위 리소스는 스토리보드에서 작업했음
	
    //Animation images
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
		
        var scrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 - (DigitalCol.bounds.width / 2));
        scrX += CGFloat(4 * DeviceGeneral.maxScrRatio);
        
        //디지털시계 이미지 스케일 조정
        DigitalCol.frame = CGRectMake(scrX, CGFloat(Double(80) * DeviceGeneral.maxScrRatio), CGFloat(Double(DigitalCol.bounds.width) * DeviceGeneral.maxScrRatio), CGFloat(Double(DigitalCol.bounds.height) * DeviceGeneral.maxScrRatio));
        //x위치를 제외한 나머지 통일
        DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat(20 * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat(12 * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat(20 * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(12 * DeviceGeneral.maxScrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        
        //Ground 크기 조절. iPad의 경우 이미지를 넓은 것으로 교체할 필요가 있음
        GroundObj.frame = CGRectMake( 0, (DeviceGeneral.scrSize?.height)! - CGFloat(75 * DeviceGeneral.maxScrRatio), CGFloat((DeviceGeneral.scrSize?.width)!) , CGFloat(75 * DeviceGeneral.maxScrRatio) );
        
        //시계 바디 및 시침 분침 위치/크기조절
        let clockScrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 - (CGFloat(245 * DeviceGeneral.maxScrRatio) / 2));
        let clockRightScrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 + (CGFloat(245 * DeviceGeneral.maxScrRatio) / 2));

        //clockScrX += CGFloat(4 * DeviceGeneral.maxScrRatio);
        var clockScrY:CGFloat = CGFloat((DeviceGeneral.scrSize?.height)! / 2 - (CGFloat(245 * DeviceGeneral.maxScrRatio) / 2));
        clockScrY += CGFloat(20 * DeviceGeneral.maxScrRatio);
        
        AnalogBody.frame = CGRectMake( clockScrX, clockScrY, CGFloat(245 * DeviceGeneral.maxScrRatio), CGFloat(245 * DeviceGeneral.maxScrRatio) );
        AnalogHours.frame = CGRectMake( clockScrX, clockScrY, CGFloat(245 * DeviceGeneral.maxScrRatio), CGFloat(245 * DeviceGeneral.maxScrRatio) );
        AnalogMinutes.frame = CGRectMake( clockScrX, clockScrY, CGFloat(245 * DeviceGeneral.maxScrRatio), CGFloat(245 * DeviceGeneral.maxScrRatio) );
        
        AnalogBodyBack.frame = CGRectMake( clockScrX - CGFloat(24 * DeviceGeneral.maxScrRatio), clockScrY - CGFloat(10 * DeviceGeneral.maxScrRatio), CGFloat(273 * DeviceGeneral.maxScrRatio), CGFloat(255 * DeviceGeneral.maxScrRatio) );
        SettingsImg.frame = CGRectMake( clockScrX - (CGFloat(135 * DeviceGeneral.maxScrRatio) / 2), clockScrY + CGFloat(125 * DeviceGeneral.maxScrRatio) , CGFloat(157 * DeviceGeneral.maxScrRatio), CGFloat(157 * DeviceGeneral.maxScrRatio) );
        AlarmListImg.frame = CGRectMake( clockRightScrX - (CGFloat(90 * DeviceGeneral.maxScrRatio) / 2), clockScrY - CGFloat(10 * DeviceGeneral.maxScrRatio), CGFloat(105 * DeviceGeneral.maxScrRatio), CGFloat(150 * DeviceGeneral.maxScrRatio) );
		
        //Astro 크기조정
        AstroCharacter.frame = CGRectMake( (DeviceGeneral.scrSize?.width)! - CGFloat(126 * DeviceGeneral.maxScrRatio), GroundObj.frame.origin.y - CGFloat(151 * DeviceGeneral.maxScrRatio) + CGFloat(9 * DeviceGeneral.maxScrRatio), CGFloat(60 * DeviceGeneral.maxScrRatio), CGFloat(151 * DeviceGeneral.maxScrRatio) );
        //Astro animations
        for i in 1...40 { //부동
            let numberStr:String = String(i).characters.count == 1 ? "0" + String(i) : String(i);
            let fileName:String = "astro" + "00" + numberStr + ".png";
            let fImage:UIImage = UIImage( named: fileName )!;
            astroMotionsStanding += [fImage];
        }
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
        }
        
        AstroCharacter.animationImages = astroMotionsStanding;
        AstroCharacter.animationDuration = 1.0;
        AstroCharacter.animationRepeatCount = -1;
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
		return CGRectMake(CGFloat(50 * DeviceGeneral.scrRatio) , ((DeviceGeneral.scrSize?.height)! - CGFloat(480 * DeviceGeneral.scrRatio)) / 2 , (DeviceGeneral.scrSize?.width)! - CGFloat(100 * DeviceGeneral.scrRatio), CGFloat(480 * DeviceGeneral.scrRatio));
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
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat(14 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat(6 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            } else {
                //원래 위치로
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat(20 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
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
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat(((8 - movesRightOffset) - movesRightOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                movesRightOffset += 6;
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat((14 - movesRightOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            } else {
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat((20 - movesRightOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat((12) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            }
        } //end of hour str
		
		//min str
        if (minString.characters.count == 1) {
            DigitalNum2.image = UIImage( named: "0.png" );
            DigitalNum3.image = UIImage( named:  minString[0] + ".png" );
            
            if (minString[0] == "1") {
                //숫자1의경우 왼쪽으로 당김.
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat(14 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);

            } else {
                //원래 위치로
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat(20 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);

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
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(6 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                movesLeftOffset += 6;
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat((14 - movesLeftOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                
            } else {
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat((20 - movesLeftOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
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
			backgroundImageView.image = UIImage( named: currentBackgroundImage + "_back" + (
				DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
				) );
			backgroundImageFadeView.image = UIImage( named: currentBackgroundImage + "_back" + (
				DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
				) );
			backgroundImageFadeView.alpha = 0;
			print("Scrsize",DeviceGeneral.scrSize?.height, (DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""));
		} else {
			//이미지가 있을 경우, 시간대가 바뀌는 경우 바꾸고 페이드
			if (currentBackgroundImage != getBackgroundFileNameFromTime(components.hour)) {
				//시간대가 바뀌어야 하는 경우
				currentBackgroundImage = getBackgroundFileNameFromTime(components.hour); //시간대 이미지 변경
				backgroundImageFadeView.alpha = 1;
				backgroundImageView.image = UIImage( named: currentBackgroundImage + "_back" + (
					DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
					) );
				
				UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
					self.backgroundImageFadeView.alpha = 0;
					}, completion: {_ in
						self.backgroundImageFadeView.image = UIImage( named: self.currentBackgroundImage + "_back" + (
							DeviceGeneral.scrSize?.height <= 480.0 ? "_4s" : ""
							) );
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


