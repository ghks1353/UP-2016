//
//  AlarmSetupGuideView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 6..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class AlarmSetupGuideView:FullScreenGuideView {
	
	override func viewDidLoad() {
		// view init func
		
		//가이드 사진/라벨 프리픽스
		guideImagePrefix = "modal-guide-alarm-images-"
		guideLabelPrefix = "guide-alarm-"
		
		guidePages = 5
		
		//Gradient
		startingGuideBackgroundGradient.colors = [
			UPUtils.colorWithHexString("1da2da").cgColor,
			UPUtils.colorWithHexString("32ca9a").cgColor
		]
		
		super.viewDidLoad() //맨 마지막에
	}
	
	override func closeGuideView() {
		//창 종료시 Alarm guide flag 저장
		DataManager.setDataBool( true, key: DataManager.settingsKeys.fullscreenAlarmGuideFlag )
		
		//이 창 종료
		self.dismiss(animated: false, completion: nil)
	} //end func
	
	
} //end class
