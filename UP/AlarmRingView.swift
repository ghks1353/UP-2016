//
//  AlarmRingView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 25..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit;

class AlarmRingView:UIViewController {
	
	//알람이 울렸을 때, 진입되는 뷰컨트롤러.
	/*
		각 게임에 대한 View를 따로 두기로 함
			- 이 뷰는 각 게임의 시작 부분에 대한 루트 뷰
	*/
	
	//게임 서브 뷰는 예외적으로 이 뷰에 포함.
	static var jumpUPStartupViewController:GameTitleViewJumpUP?;
	
	
	var currentAlarmElement:AlarmElements?;
	
	//Test elements
	/*var alarmNameLabel:UILabel = UILabel();
	var alarmOffUIButton:UIButton = UIButton();*/
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor();
		
		/*alarmNameLabel.frame = CGRectMake(0, 48, self.view.frame.width, 40);
		alarmNameLabel.font = UIFont.systemFontOfSize(28);
		alarmNameLabel.textAlignment = .Center;
		alarmNameLabel.textColor = UIColor.blackColor();
		alarmOffUIButton.frame = CGRectMake(0, self.view.frame.height - 48, self.view.frame.width, 24);
		alarmOffUIButton.setTitle("알림끄기", forState: .Normal);
		alarmOffUIButton.setTitleColor(UIColor.blackColor(), forState: .Normal);
		alarmOffUIButton.addTarget(self, action: "alarmOffTest:", forControlEvents: .TouchUpInside);
		self.view.addSubview(alarmNameLabel); self.view.addSubview(alarmOffUIButton);*/
		
	}
	
	override func viewDidAppear(animated: Bool) {
		if (currentAlarmElement != nil) {
			
			//게임을 분류하여 각각 맞는 view를 present
			var gameSel:Int = 0; //랜덤일 경우 여기서 랜덤 선택
			if (currentAlarmElement?.gameSelected == -1) {
				gameSel = Int(arc4random_uniform( UInt32(UPAlarmGameLists.list.count) ));
			} //rdm sel end
			
			switch( gameSel ) {
			case 0: //점프업
				if (AlarmRingView.jumpUPStartupViewController == nil) {
					AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP();
				}
				self.presentViewController(AlarmRingView.jumpUPStartupViewController!, animated: false, completion: nil);
				break;
				
			default:
				print("game code", gameSel, "not found err");
				break;
			}
			
			
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		//뷰가 열릴 직전에.
		
		currentAlarmElement = AlarmManager.getRingingAlarm();
		if (currentAlarmElement == nil) {
			print("alarm element is nil");
		} else {
			
			
		} //end if
		
		
		
		
	} //end func
	
	override func viewWillDisappear(animated: Bool) {
		
		
	}
	
	/*
	func alarmOffTest(sender: UIButton) {
		//alarm off and close this view
		
		AlarmManager.gameClearToggleAlarm( (currentAlarmElement?.alarmID)!, cleared: true );
		AlarmManager.mergeAlarm(); //Merge it
		
		AlarmManager.alarmRingActivated = false;
		
		//Refresh tables
		AlarmListView.selfView?.createTableList();
		
		self.dismissViewControllerAnimated(true, completion: nil); //dismiss this view
	}*/
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}