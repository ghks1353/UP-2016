//
//  DeviceGeneral.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit;

class DeviceGeneral {
    
    //기기 해상도 bounds
	static var scrSize:CGRect?; static var scrSizeForCalcuate:CGRect?;
    //기준 해상도 (iPhone 6s plus)
    static let workSize:CGRect = CGRect(x: 0, y: 0, width: 414, height: 736);
    //기준에 대한 비율
    static var scrRatio:Double = 1; static var maxScrRatio:Double = 1; //최대가 1인 비율 크기
	static var scrRatioC:CGFloat = 1; static var maxScrRatioC:CGFloat = 1;
	
	//낮은 해상도 사용
	static var usesLowQualityImage:Bool = false;
	//평균 Modal size
	static var defaultModalSizeRect:CGRect = CGRect();
	
	//chk is back or not
	static var appIsBackground:Bool = false;
	
	////// Is 24hours or not
	static var is24HourMode:Bool = false;
	
    static func initialDeviceSize() {
        //화면 사이즈를 얻어옴.
        scrSize = UIScreen.mainScreen().bounds;
		scrSizeForCalcuate = scrSize;
		//가로로 init되는 경우, 세로로init되게 함. (왜냐면 디자인은 다 세로의 배율 기준이기 때문임)
		//print("Initing device. state landscape is ", UIDevice.currentDevice().orientation.isLandscape == true);
		if (UIDevice.currentDevice().orientation.isLandscape == true || scrSize!.width > scrSize!.height) {
			scrSizeForCalcuate = CGRectMake( 0, 0, scrSize!.height, scrSize!.width );
		}
		
		scrRatio = Double((scrSizeForCalcuate!.width) / workSize.width);

		print("Width", scrSize!.width, "Height", scrSize!.height, "Ratio", scrRatio);
		
        scrRatioC = CGFloat(scrRatio);
        //패드에서 거하게 커지는 현상방지
		maxScrRatio = min(1, scrRatio); maxScrRatioC = CGFloat(maxScrRatio);
		
		//저퀄리티 사진사용 체크
		usesLowQualityImage = Double(scrSizeForCalcuate!.width) <= 500 ? true : false;
		
		print("Checking user interface ipad is", UIDevice.currentDevice().userInterfaceIdiom == .Pad);
		changeModalSize();
		
		//오전/오후 체크
		let formatString:NSString = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())!;
		is24HourMode = !formatString.containsString("a"); // true - 24시모드 / false - 12시모드
		
    }
	
	static func changeDeviceSizeWith( size:CGSize ) {
		scrSize = CGRectMake(0, 0, size.width, size.height);
		
		print("Initing device. state landscape is ", UIDevice.currentDevice().orientation.isLandscape == true);
		if (UIDevice.currentDevice().orientation.isLandscape == true) {
			scrSizeForCalcuate = CGRectMake( 0, 0, scrSize!.height, scrSize!.width );
		}
		changeModalSize();
		
		
		print("Screen size changed to width", size.width, "height", size.height);
	}
	
	static func changeModalSize() {
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
			//패드의 경우, 크기를 미리 지정해줌
			defaultModalSizeRect = CGRectMake(((scrSize!.width) - 320) / 2, ((scrSize!.height) - 480) / 2 , 320, 480);
		} else {
			//기타 (폰)의 경우
			defaultModalSizeRect = CGRectMake(50 * DeviceGeneral.scrRatioC , (scrSizeForCalcuate!.height - (480 * DeviceGeneral.scrRatioC)) / 2 , scrSizeForCalcuate!.width - (100 * DeviceGeneral.scrRatioC), (480 * DeviceGeneral.scrRatioC));
		}
		
		print("Modal size changed to width ", defaultModalSizeRect.width, "height", defaultModalSizeRect.height);
	}
	
}