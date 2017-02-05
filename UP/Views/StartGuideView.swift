//
//  StartGuideView.swift
//  UP
//
//  Created by ExFl on 2016. 7. 1..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class StartGuideView:FullScreenGuideView {
	
	///////// 시작 가이드 뷰
	static var selfView:StartGuideView?
	
	override func viewDidLoad() {
		// view init func
		
		//가이드 사진/라벨 프리픽스
		guideImagePrefix = "modal-guide-images-"
		guideLabelPrefix = "guide-start-"

		guidePages = 4
		StartGuideView.selfView = self
		
		//Gradient
		startingGuideBackgroundGradient.colors = [
			UPUtils.colorWithHexString("2e2c4e").cgColor,
			UPUtils.colorWithHexString("4e3f65").cgColor,
			UPUtils.colorWithHexString("764f74").cgColor,
			UPUtils.colorWithHexString("965778").cgColor,
			UPUtils.colorWithHexString("c86879").cgColor,
			UPUtils.colorWithHexString("df7e7a").cgColor,
			UPUtils.colorWithHexString("e9a678").cgColor
		]
		
		super.viewDidLoad() //맨 마지막에
	}
	
	override func closeGuideView() {
		//창 종료시 Startguide 봤다고 저장
		DataManager.setDataBool( true, key: DataManager.settingsKeys.startGuideFlag )
		
		//이 창 종료
		self.dismiss(animated: false, completion: nil)
		
		//이 가이드의 부모가 메인인 경우 공지 띄움 호출 트리거
		if (self.presentingViewController is ViewController) {
			(self.presentingViewController as! ViewController).callShowNoticeModal()
		} //end if [parent check]
	} //end func
	
		
} //end class
