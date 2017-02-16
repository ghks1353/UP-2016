//
//  AchievementElement.swift
//  UP
//
//  Created by ExFl on 2016. 5. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class AchievementData {
	
	var achievementID:String = ""
	var achievementGameCenterID:String = ""
	
	/////// Key: LanguagesManager.LanguageCode
	/////// Value: Localized variables
	var name:[String:String] = [:]
	var description:[String:String] = [:]
	
	//도전과제 / 설명 숨김 여부
	var achievementHidden:Bool = false
	var descriptionHidden:Bool = false
	
	//차례로 변수명, 연산자, 비교값
	var aVariables:[String] = []
	var aComparsions:[String] = []
	var aValues:[Double] = []
	
	/// 차례로 보상 ID, 보상 값
	var aRewards:[String] = []
	var aRewardAmount:[Double] = []
	
	/// 클리어 여부.
	var cleared:Bool = false
	
}
