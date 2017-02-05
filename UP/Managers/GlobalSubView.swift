//
//  GlobalSubView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 6..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit;

class GlobalSubView {
	
	//각 클래스에 새로선언 시 초기화크래시때문에 미리선언함
	
	//Modals
	static var alarmAddView:AddAlarmView = AddAlarmView()
	
	//Ring views / Game views
	static var alarmRingViewcontroller:AlarmRingView = AlarmRingView()
	static var gameModePlayViewcontroller:GameModeView = GameModeView()
	
	//Popviews
	static var alarmStatisticsDataPointView:StatisticsDataPointView = StatisticsDataPointView()
	static var alarmSoundListView:AlarmSoundListView = AlarmSoundListView()
	static var alarmGameListView:AlarmGameListView = AlarmGameListView()
	static var alarmRepeatSettingsView:AlarmRepeatSettingsView = AlarmRepeatSettingsView()
	
	//No nav modals
	static var alarmGameResultView:GameResultView = GameResultView()
	static var alarmGamePlayWindowView:GamePlayWindowView = GamePlayWindowView()
	
	//Start guide
	static var startingGuideView:StartGuideView = StartGuideView()
	
	//Full-screen Alarm guide
	static var alarmSetupGuideView:AlarmSetupGuideView = AlarmSetupGuideView()
	
}
