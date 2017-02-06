//
//  AlarmListOverlayGuideView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 6..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class AlarmListOverlayGuideView:UIOverlayGuideView {
	
	//Nav height
	var modalNavHeight:CGFloat = 0
	
	//가이드 오버레이: 알람추가
	var guideAddAlarmImage:UIImageView = UIImageView()
	var guideAddAlarmLabel:UILabel = UILabel()
	
	//가이드: 알람 리스트 두 개 (이미지 아니고 직접 그림)
	var guideAlarmListFirstView:UIView = UIView()
	var guideAlarmListSecondView:UIView = UIView()
	
	//가이드 삭제버튼
	var guideRemoveButtonImage:UIImageView = UIImageView()
	var guideRemoveLabel:UILabel = UILabel()
	
	//가이드 시간 (꾸밈용)
	var guideTimeDecorationFirstImage:UIImageView = UIImageView()
	var guideTimeDecorationSecondImage:UIImageView = UIImageView()
	
	//on/off switch (가이드용 1, 꾸밈용 1)
	var guideOnOFFSwitchImage:UIImageView = UIImageView()
	var guideOnOFFSwitchSecondImage:UIImageView = UIImageView()
	var guideOnOFFSwitchLabel:UILabel = UILabel()
	
	//편집/삭제 화살표
	var guideTapEditImage:UIImageView = UIImageView()
	var guideSwipeDeleteImage:UIImageView = UIImageView()
	
	var guideTapEditLabel:UILabel = UILabel()
	var guideSwipeDeleteLabel:UILabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		///// Image setup
		guideAddAlarmImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-add.png" )
		guideRemoveButtonImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-del.png" )
		
		/// 시간 데코
		guideTimeDecorationFirstImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-time.png" )
		guideTimeDecorationSecondImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-time-half.png" )
		
		//스위치 이미지
		guideOnOFFSwitchImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-on.png" )
		guideOnOFFSwitchSecondImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-off.png" )
		
		//탭 및 스와이프 가이드
		guideTapEditImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-swipe-edit.png" )
		guideSwipeDeleteImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-list-swipe-del.png" )
		
		///// Label setup
		
		// 알람 추가 라벨
		guideAddAlarmLabel.textAlignment = .right
		guideAddAlarmLabel.textColor = UIColor.white
		guideAddAlarmLabel.font = UIFont.systemFont(ofSize: 18)
		guideAddAlarmLabel.text = LanguagesManager.$("addAlarm")
		
		// 삭제쪽 라벨
		guideRemoveLabel.textAlignment = .right
		guideRemoveLabel.textColor = UIColor.white
		guideRemoveLabel.font = UIFont.systemFont(ofSize: 18)
		guideRemoveLabel.text = LanguagesManager.$("alarmDelete")
		
		//온오프 스위치 (온쪽) 라벨
		guideOnOFFSwitchLabel.textAlignment = .right
		guideOnOFFSwitchLabel.textColor = UIColor.white
		guideOnOFFSwitchLabel.font = UIFont.systemFont(ofSize: 18)
		guideOnOFFSwitchLabel.text = LanguagesManager.$("alarmListOverlayToggle")
		
		
		//탭 및 스와이프 라벨
		guideTapEditLabel.textAlignment = .left
		guideTapEditLabel.textColor = UIColor.white
		guideTapEditLabel.font = UIFont.systemFont(ofSize: 18)
		guideTapEditLabel.text = LanguagesManager.$("alarmListOverlayEdit")
		
		guideSwipeDeleteLabel.textAlignment = .right
		guideSwipeDeleteLabel.textColor = UIColor.white
		guideSwipeDeleteLabel.font = UIFont.systemFont(ofSize: 18)
		guideSwipeDeleteLabel.text = LanguagesManager.$("alarmListOverlayDelete")
		
		
		//////add views
		self.view.addSubview(guideAddAlarmImage)
		self.view.addSubview(guideAlarmListFirstView)
		self.view.addSubview(guideAlarmListSecondView)
		
		self.view.addSubview(guideRemoveButtonImage)
		
		self.view.addSubview(guideTimeDecorationFirstImage)
		self.view.addSubview(guideTimeDecorationSecondImage)
		
		self.view.addSubview(guideOnOFFSwitchImage)
		self.view.addSubview(guideOnOFFSwitchSecondImage)
		
		self.view.addSubview(guideTapEditImage)
		self.view.addSubview(guideSwipeDeleteImage)
		
		////// add label views
		self.view.addSubview(guideAddAlarmLabel)
		self.view.addSubview(guideRemoveLabel)
		self.view.addSubview(guideOnOFFSwitchLabel)
		
		self.view.addSubview(guideTapEditLabel)
		self.view.addSubview(guideSwipeDeleteLabel)
		
		
	} //end func
	
	override func fitFrames() {
		super.fitFrames()
		
		var xAxisPreset:CGFloat = 0
		//var yAxisPreset:CGFloat = 0
		
		//Pad에서 전체 modal크기가 조금 이상하게 잡힘
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			xAxisPreset = 4
			//yAxisPreset = 3
		}
		
		guideAddAlarmImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.maxX - (16 + 77.5),
			y: DeviceManager.defaultModalSizeRect.minY - (24 /* * DeviceManager.maxScrRatioC*/),
			width: 77.5/* * DeviceManager.maxScrRatioC*/,
			height: 57.6/* * DeviceManager.maxScrRatioC*/
		)
		//Alarm List 직접 그려야하므로 모달크기, 세로80
		guideAlarmListFirstView.frame = CGRect(
			x: (DeviceManager.defaultModalSizeRect.minX + xAxisPreset),
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight,
			width: (DeviceManager.defaultModalSizeRect.width - xAxisPreset * 2),
			height: 80 /* Alarm list에 정의된값. */
		)
		guideAlarmListSecondView.frame = CGRect(
			x: guideAlarmListFirstView.frame.minX,
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + (80 - 2) /* <- 1번째 리스트 높이값 - border값 */,
			width: guideAlarmListFirstView.frame.width - 68.3 /* 삭제버튼 크기 */,
			height: (80 + 2) /* Alarm list에 정의된값. + border값 */
		)

		guideAlarmListFirstView.layer.borderWidth = 2
		guideAlarmListFirstView.layer.borderColor = UIColor.white.cgColor
		guideAlarmListSecondView.layer.borderWidth = guideAlarmListFirstView.layer.borderWidth
		guideAlarmListSecondView.layer.borderColor = guideAlarmListFirstView.layer.borderColor
		
		/// 삭제버튼 부분 이미지 프레임
		guideRemoveButtonImage.frame = CGRect(
			x: guideAlarmListSecondView.frame.maxX,
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + 80,
			width: 68.3,
			height: 240.05
		)
		//시간 부분 데코레이션
		guideTimeDecorationFirstImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.minX + xAxisPreset + 12,
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + 12,
			width: 134.6,
			height: 56.6
		)
		guideTimeDecorationSecondImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.minX + xAxisPreset, //mask 비슷한 효과가 나야 하므로 붙임
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + 80 + 12,
			width: 79.4,
			height: 32.2
		)
		//토글 이미지
		guideOnOFFSwitchImage.frame = CGRect(
			x: guideAlarmListFirstView.frame.maxX - (14 + 88.7),
			y: guideAlarmListFirstView.frame.minY + 23,
			width: 88.7,
			height: 49.8
		)
		guideOnOFFSwitchSecondImage.frame = CGRect(
			x: guideAlarmListSecondView.frame.maxX - (14 + 55),
			y: guideAlarmListSecondView.frame.minY + 23,
			width: 55,
			height: 32.85
		)
		
		/// 탭하여 편집, 스와이프하여 삭제
		guideTapEditImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.minX + xAxisPreset + 12,
			y: guideTimeDecorationSecondImage.frame.maxY + 3,
			width: 49.6,
			height: 115.05
		)
		guideSwipeDeleteImage.frame = CGRect(
			x: guideTapEditImage.frame.maxX + 48,
			y: guideTimeDecorationSecondImage.frame.maxY + 15,
			width: 95.5,
			height: 127.3
		)
		
		/////////////////
		// labels
		
		guideAddAlarmLabel.frame = CGRect(
			x: guideAddAlarmImage.frame.minX - ((8 + 150) * DeviceManager.maxScrRatioC),
			y: guideAddAlarmImage.frame.minY - (10 * DeviceManager.maxScrRatioC),
			width: 150 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		guideRemoveLabel.frame = CGRect(
			x: guideRemoveButtonImage.frame.maxX - ((4 + 200) * DeviceManager.maxScrRatioC),
			y: guideRemoveButtonImage.frame.maxY + (4 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		/// toggle label
		guideOnOFFSwitchLabel.frame = CGRect(
			x: guideOnOFFSwitchImage.frame.minX - ((8 + 200) * DeviceManager.maxScrRatioC),
			y: guideOnOFFSwitchImage.frame.maxY - (21 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		//편집/삭제라벨
		guideTapEditLabel.frame = CGRect(
			x: guideTapEditImage.frame.minX - (24 * DeviceManager.maxScrRatioC),
			y: guideTapEditImage.frame.maxY + (3 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		guideSwipeDeleteLabel.frame = CGRect(
			x: guideSwipeDeleteImage.frame.maxX - ((-8 + 200) * DeviceManager.maxScrRatioC),
			y: guideSwipeDeleteImage.frame.maxY + (3 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
	} //end func override fitframes
	
	override func closeGuideView(_ gst: UITapGestureRecognizer) {
		super.closeGuideView(gst)
		
		//창 닫을 때 알람 리스트 오버레이 가이드 보았음을 저장
		DataManager.setDataBool( true, key: DataManager.settingsKeys.overlayGuideAlarmListFlag )
		
	} //end func
	
}
