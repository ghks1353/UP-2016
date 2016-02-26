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
	//디자인이 올때까지 임시로 디자인 하죠.
	
	var currentAlarmElement:AlarmElements?;
	
	//Test elements
	var alarmNameLabel:UILabel = UILabel();
	var alarmOffUIButton:UIButton = UIButton();
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.whiteColor();
		
		alarmNameLabel.frame = CGRectMake(0, 48, self.view.frame.width, 40);
		alarmNameLabel.font = UIFont.systemFontOfSize(28);
		alarmNameLabel.textAlignment = .Center;
		alarmNameLabel.textColor = UIColor.blackColor();
		
		alarmOffUIButton.frame = CGRectMake(0, self.view.frame.height - 48, self.view.frame.width, 24);
		alarmOffUIButton.setTitle("알림끄기", forState: .Normal);
		alarmOffUIButton.setTitleColor(UIColor.blackColor(), forState: .Normal);
		alarmOffUIButton.addTarget(self, action: "alarmOffTest:", forControlEvents: .TouchUpInside);
		
		self.view.addSubview(alarmNameLabel); self.view.addSubview(alarmOffUIButton);
	}
	
	override func viewWillAppear(animated: Bool) {
		//뷰가 열릴 직전에.
		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default;
		
		currentAlarmElement = AlarmManager.getRingingAlarm();
		if (currentAlarmElement == nil) {
			print("alarm element is nil");
		} else {
			alarmNameLabel.text = currentAlarmElement?.alarmName;
			
			
		} //end if
	} //end func
	
	override func viewWillDisappear(animated: Bool) {
		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
		
	}
	
	func alarmOffTest(sender: UIButton) {
		//alarm off and close this view
		
		AlarmManager.gameClearToggleAlarm( (currentAlarmElement?.alarmID)!, cleared: true );
		AlarmManager.mergeAlarm(); //Merge it
		
		AlarmManager.alarmRingActivated = false;
		
		//Refresh tables
		AlarmListView.selfView?.createTableList();
		
		self.dismissViewControllerAnimated(true, completion: nil); //dismiss this view
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}