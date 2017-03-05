//
//  DeviceManager.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit;

class DeviceManager {
    
    //기기 해상도 bounds
	static var scrSize:CGRect?; static var scrSizeForCalcuate:CGRect?;
    //기준 해상도 (iPhone 6s plus)
    static let workSize:CGRect = CGRect(x: 0, y: 0, width: 414, height: 736)
    //기준에 대한 비율
    static var scrRatio:Double = 1; static var maxScrRatio:Double = 1; //최대가 1인 비율 크기
	static var scrRatioC:CGFloat = 1; static var maxScrRatioC:CGFloat = 1;
	static var modalRatioC:CGFloat = 1; static var maxModalRatioC:CGFloat = 1; //modal에서 조정이 필요할 때 사용. 특히 태블릿에서.
	static var resultModalRatioC:CGFloat = 1; static var resultMaxModalRatioC:CGFloat = 1;
	
	//낮은 해상도 사용
	static var usesLowQualityImage:Bool = false
	//평균 Modal size
	static var defaultModalSizeRect:CGRect = CGRect()
	
	//Result / 게임시작 창 Modal size
	static var resultModalSizeRect:CGRect = CGRect()
	
	//chk is back or not
	static var appIsBackground:Bool = false
	
	////// Is 24hours or not
	static var is24HourMode:Bool = false
	
	//is 4s or not
	static var isiPhone4S:Bool = false
	// is iPad or not
	static var isiPad:Bool = false
	
    static func initialDeviceSize() {
        //화면 사이즈를 얻어옴.
        scrSize = UIScreen.main.bounds
		scrSizeForCalcuate = scrSize
		//가로로 init되는 경우, 세로로init되게 함. (왜냐면 디자인은 다 세로의 배율 기준이기 때문임)
		//print("Initing device. state landscape is ", UIDevice.currentDevice().orientation.isLandscape == true);
		if (UIDevice.current.orientation.isLandscape == true || scrSize!.width > scrSize!.height) {
			scrSizeForCalcuate = CGRect( x: 0, y: 0, width: scrSize!.height, height: scrSize!.width )
		} //end if
		
		scrRatio = Double((scrSizeForCalcuate!.width) / workSize.width)

		print("[DeviceManager] Width", scrSize!.width, "Height", scrSize!.height, "Ratio", scrRatio)
		
        scrRatioC = CGFloat(scrRatio)
        //패드에서 거하게 커지는 현상방지
		maxScrRatio = min(1, scrRatio)
		maxScrRatioC = CGFloat(maxScrRatio)
		
		//저퀄리티 사진사용 체크
		usesLowQualityImage = Double(scrSizeForCalcuate!.height) <= 500 ? true : false
		
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			DeviceManager.isiPad = true
		} //end if
		
		changeModalSize()
		
		if (!DeviceManager.isiPad && scrSize!.height <= 480) {
			isiPhone4S = true
		} //end if
		
		//오전/오후 체크
		let formatString:String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as String
		is24HourMode = !formatString.contains("a") // true - 24시모드 / false - 12시모드
		
    } //end func
	
	static func changeDeviceSizeWith( _ size:CGSize ) {
		scrSize = CGRect(x: 0, y: 0, width: size.width, height: size.height);
		
		print("[DeviceManager] Initing device. state landscape is ", UIDevice.current.orientation.isLandscape == true)
		if (UIDevice.current.orientation.isLandscape == true) {
			scrSizeForCalcuate = CGRect( x: 0, y: 0, width: scrSize!.height, height: scrSize!.width )
		} //end if
		changeModalSize()
		
		
		print("[DeviceManager] Screen size changed to width", size.width, "height", size.height);
	} //end func
	
	static func changeModalSize() {
		
		if (DeviceManager.isiPad) {
			//패드의 경우, 크기를 미리 지정해줌
			defaultModalSizeRect = CGRect(x: ((scrSize!.width) - 320) / 2, y: ((scrSize!.height) - 480) / 2 , width: 320, height: 480)
			resultModalSizeRect = CGRect(x: ((scrSize!.width) - 334) / 2, y: ((scrSize!.height) - 460) / 2 , width: 334, height: 460)
			
			modalRatioC = CGFloat(defaultModalSizeRect.width / (workSize.width - 100))
			maxModalRatioC = min(1, modalRatioC)
			
			resultModalRatioC = CGFloat(resultModalSizeRect.width / (workSize.width - 100))
			resultMaxModalRatioC = min(1, resultModalRatioC)
		} else { //기타 (폰)의 경우
			defaultModalSizeRect = CGRect(x: 50 * DeviceManager.scrRatioC , y: (scrSizeForCalcuate!.height - (480 * DeviceManager.scrRatioC)) / 2 , width: scrSizeForCalcuate!.width - (100 * DeviceManager.scrRatioC), height: (480 * DeviceManager.scrRatioC))
			resultModalSizeRect = CGRect(x: 50 * DeviceManager.scrRatioC , y: (scrSizeForCalcuate!.height - (460 * DeviceManager.scrRatioC)) / 2 , width: scrSizeForCalcuate!.width - (100 * DeviceManager.scrRatioC), height: (460 * DeviceManager.scrRatioC))
			
			modalRatioC = DeviceManager.scrRatioC
			maxModalRatioC = min(1, modalRatioC)
			
			resultModalRatioC = DeviceManager.scrRatioC
			resultMaxModalRatioC = min(1, resultModalRatioC)
		} //end if
		
		print("[DeviceManager] Modal size changed to width ", defaultModalSizeRect.width, "height", defaultModalSizeRect.height)
	} //end func
	
} //end class
