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
    @IBOutlet weak var MainBackDecoration: UIImageView!
    
    @IBOutlet weak var AstroCharacter: UIImageView!
    
    //Animation images
        //스탠딩 모션
    var astroMotionsStanding:Array<UIImage> = [];
        //달리기
    var astroMotionsRunning:Array<UIImage> = [];
        //점프
    var astroMotionsJumping:Array<UIImage> = [];
   
    
    //Modal views
    var modalSettingsView:SettingsView?;
    var modalAlarmListView:AlarmListView?;
    
    //viewdidload - inital 함수. 뷰 로드시 자동실행
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //Init device size factor
        DeviceGeneral.initialDeviceSize();
        
        var scrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 - (DigitalCol.bounds.width / 2));
        scrX += CGFloat(4 * DeviceGeneral.scrRatio);
        
        //디지털시계 이미지 스케일 조정
        DigitalCol.frame = CGRectMake(scrX, CGFloat(Double(80) * DeviceGeneral.scrRatio), CGFloat(Double(DigitalCol.bounds.width) * DeviceGeneral.scrRatio), CGFloat(Double(DigitalCol.bounds.height) * DeviceGeneral.scrRatio));
        //x위치를 제외한 나머지 통일
        DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat(20 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat(20 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
        
        //Ground 크기 조절. iPad의 경우 이미지를 넓은 것으로 교체할 필요가 있음
        GroundObj.frame = CGRectMake( 0, (DeviceGeneral.scrSize?.height)! - CGFloat(GroundObj.frame.height * CGFloat(DeviceGeneral.scrRatio)), (DeviceGeneral.scrSize?.width)!, CGFloat(71.05 * DeviceGeneral.scrRatio) );
        
        //시계 바디 및 시침 분침 위치/크기조절
        let clockScrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 - (CGFloat(245 * DeviceGeneral.scrRatio) / 2));
        let clockRightScrX:CGFloat = CGFloat((DeviceGeneral.scrSize?.width)! / 2 + (CGFloat(245 * DeviceGeneral.scrRatio) / 2));

        //clockScrX += CGFloat(4 * DeviceGeneral.scrRatio);
        var clockScrY:CGFloat = CGFloat((DeviceGeneral.scrSize?.height)! / 2 - (CGFloat(245 * DeviceGeneral.scrRatio) / 2));
        clockScrY += CGFloat(20 * DeviceGeneral.scrRatio);
        
        AnalogBody.frame = CGRectMake( clockScrX, clockScrY, CGFloat(245 * DeviceGeneral.scrRatio), CGFloat(245 * DeviceGeneral.scrRatio) );
        AnalogHours.frame = CGRectMake( clockScrX, clockScrY, CGFloat(245 * DeviceGeneral.scrRatio), CGFloat(245 * DeviceGeneral.scrRatio) );
        AnalogMinutes.frame = CGRectMake( clockScrX, clockScrY, CGFloat(245 * DeviceGeneral.scrRatio), CGFloat(245 * DeviceGeneral.scrRatio) );
        
        AnalogBodyBack.frame = CGRectMake( clockScrX - CGFloat(24 * DeviceGeneral.scrRatio), clockScrY - CGFloat(10 * DeviceGeneral.scrRatio), CGFloat(273 * DeviceGeneral.scrRatio), CGFloat(255 * DeviceGeneral.scrRatio) );
        SettingsImg.frame = CGRectMake( clockScrX - (CGFloat(135 * DeviceGeneral.scrRatio) / 2), clockScrY + CGFloat(125 * DeviceGeneral.scrRatio) , CGFloat(157 * DeviceGeneral.scrRatio), CGFloat(157 * DeviceGeneral.scrRatio) );
        AlarmListImg.frame = CGRectMake( clockRightScrX - (CGFloat(90 * DeviceGeneral.scrRatio) / 2), clockScrY - CGFloat(10 * DeviceGeneral.scrRatio), CGFloat(105 * DeviceGeneral.scrRatio), CGFloat(150 * DeviceGeneral.scrRatio) );
        
        MainBackDecoration.frame = CGRectMake( 0, (DeviceGeneral.scrSize?.height)! - CGFloat(192 * DeviceGeneral.scrRatio), CGFloat(414 * DeviceGeneral.scrRatio), CGFloat(192 * DeviceGeneral.scrRatio) );
        
        //Astro 크기조정
        AstroCharacter.frame = CGRectMake( (DeviceGeneral.scrSize?.width)! - CGFloat(126 * DeviceGeneral.scrRatio), GroundObj.frame.origin.y - CGFloat(151 * DeviceGeneral.scrRatio) + CGFloat(9 * DeviceGeneral.scrRatio), CGFloat(63 * DeviceGeneral.scrRatio), CGFloat(151 * DeviceGeneral.scrRatio) );
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
        let generalModalRect:CGRect = CGRectMake(CGFloat(50 * DeviceGeneral.scrRatio) , ((DeviceGeneral.scrSize?.height)! - CGFloat(480 * DeviceGeneral.scrRatio)) / 2 , (DeviceGeneral.scrSize?.width)! - CGFloat(100 * DeviceGeneral.scrRatio), CGFloat(480 * DeviceGeneral.scrRatio));
        modalSettingsView = SettingsView(); modalSettingsView!.setupModalView( generalModalRect );
        modalAlarmListView = AlarmListView();
		modalAlarmListView!.setupModalView( generalModalRect );
        
        
        //(테스트) 시계 이미지 터치시
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
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
        
        
        //Startup permission request
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings);
        
        //Startup language initial
        Languages.initLanugages( NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String );
		
		
		
       updateTimeAnimation(); //first call
       setInterval(0.5, block: updateTimeAnimation);
    }
    
    func openSettingsView (gestureRecognizer: UITapGestureRecognizer) {
        //환경설정 열기
        modalSettingsView?.modalPresentationStyle = .OverFullScreen;
        self.presentViewController(modalSettingsView!, animated: true, completion: nil);
    }
    func openAlarmlistView (gestureRecognizer: UITapGestureRecognizer) {
        //Alarmlist view 열기
        modalAlarmListView?.modalPresentationStyle = .OverFullScreen;
        self.presentViewController(modalAlarmListView!, animated: true, completion: nil);
    }
    
    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        
        //이동할 뷰 컨트롤러 인스턴스 생성
        let uvc = self.storyboard?.instantiateViewControllerWithIdentifier("testGameViewID")
        
        //화면 전환 스타일 설정
        uvc?.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        //화면 전환
        self.presentViewController(uvc!, animated: true, completion: nil)
        
    }
    
  
    func updateTimeAnimation() {
        //setinterval call
        
        //get time and calcuate
        let date = NSDate(); let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date);
        
        let hourString:String = String(components.hour);
        let minString:String = String(components.minute);
        
        if hourString.utf8.count == 1 {
            DigitalNum0.image = UIImage( named: "0.png" );
            DigitalNum1.image = UIImage( named:  hourString[0] + ".png" );
            
            if hourString[0] == "1" {
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
             if hourString[0] == "1" {
                //오른쪽으로 당김
                movesRightOffset += 6;
            }
			
            if hourString[1] == "1" {
                //가능한 경우 최대 두번 당김
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat((8 - movesRightOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                movesRightOffset += 6;
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat((14 - movesRightOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            } else {
                DigitalNum0.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width*2 - CGFloat((20 - movesRightOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum1.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) - DigitalCol.frame.width - CGFloat((12) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            }
            
            
            
        }
        if minString.utf8.count == 1 {
            DigitalNum2.image = UIImage( named: "0.png" );
            DigitalNum3.image = UIImage( named:  minString[0] + ".png" );
            
            if minString[0] == "1" {
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
            if minString[1] == "1" {
                //가능한 경우 최대 두번 당김
                movesLeftOffset += 6;
            }
            
            if minString[0] == "1" {
                //왼쪽으로 당김
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(6 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                movesLeftOffset += 6;
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat((14 - movesLeftOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                
            } else {
                DigitalNum2.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + CGFloat(12 * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
                DigitalNum3.frame = CGRectMake((DigitalCol.frame.minX + (DigitalCol.frame.width / 2)) + DigitalCol.frame.width + CGFloat((20 - movesLeftOffset) * DeviceGeneral.scrRatio), DigitalCol.frame.minY, DigitalCol.frame.width, DigitalCol.frame.height);
            }
            
           

            
        }
        
        if !DigitalCol.hidden {
            //1초주기 실행
            let secondmov:Double = Double(components.minute) / 60 / 12;
            AnalogHours.transform = CGAffineTransformMakeRotation(CGFloat(((Double(components.hour) / 12) + secondmov) * 360) * CGFloat(M_PI) / 180 );
            AnalogMinutes.transform = CGAffineTransformMakeRotation(CGFloat((Double(components.minute) / 60) * 360) * CGFloat(M_PI) / 180 );
			
        }
        
        DigitalCol.hidden = !DigitalCol.hidden;
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
