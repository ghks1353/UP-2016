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
    static var scrSize:CGRect?;
    //기준 해상도 (iPhone 6s plus)
    static let workSize:CGRect = CGRect(x: 0, y: 0, width: 414, height: 736);
    //기준에 대한 비율
    static var scrRatio:Double = 1; static var maxScrRatio:Double = 1; //최대가 1인 비율 크기
	static var scrRatioC:CGFloat = 1; static var maxScrRatioC:CGFloat = 1;
	
	//낮은 해상도 사용
	static var usesLowQualityImage:Bool = false;
	//평균 Modal size
	static var defaultModalSizeRect:CGRect = CGRect();
	
	static var appIsBackground:Bool = false;
	
    static func initialDeviceSize() {
        //화면 사이즈를 얻어옴.
        scrSize = UIScreen.mainScreen().bounds;
        scrRatio = Double((scrSize?.width)! / workSize.width);
		scrRatioC = CGFloat(scrRatio);
		
        print("Width", scrSize?.width, "Height", scrSize?.height, "Ratio", scrRatio);
        
        //패드에서 거하게 커지는 현상방지
		maxScrRatio = min(1, scrRatio);
		maxScrRatioC = CGFloat(maxScrRatio);
		
		//저퀄리티 사진사용 체크
		if (Double(scrSize!.height) <= 500) {
			usesLowQualityImage = true;
			print("Using low-quality pic");
		}
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
			//패드의 경우, 크기를 미리 지정해줌
			defaultModalSizeRect = CGRectMake(((DeviceGeneral.scrSize?.width)! - 320) / 2, ((DeviceGeneral.scrSize?.height)! - 480) / 2 , 320, 480);
		} else {
			//기타 (폰)의 경우
			defaultModalSizeRect = CGRectMake(50 * DeviceGeneral.scrRatioC , ((DeviceGeneral.scrSize?.height)! - (480 * DeviceGeneral.scrRatioC)) / 2 , (DeviceGeneral.scrSize?.width)! - (100 * DeviceGeneral.scrRatioC), (480 * DeviceGeneral.scrRatioC));
		}
    }
    
}