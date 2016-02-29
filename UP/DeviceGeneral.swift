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
	static var scrRatioC:CGFloat = 1;
	
	//낮은 해상도 사용
	static var usesLowQualityImage:Bool = false;
	//평균 Modal size
	static var defaultModalSizeRect:CGRect = CGRect();
	
	
    static func initialDeviceSize() {
        //화면 사이즈를 얻어옴.
        scrSize = UIScreen.mainScreen().bounds;
        scrRatio = Double((scrSize?.width)! / workSize.width);
		scrRatioC = CGFloat(scrRatio);
		
        print("Width", scrSize?.width, "Height", scrSize?.height, "Ratio", scrRatio);
        
        //패드에서 거하게 커지는 현상방지
        maxScrRatio = min(1, scrRatio);
		
		//저퀄리티 사진사용 체크
		if (Double(scrSize!.height) <= 500) {
			usesLowQualityImage = true;
			print("Using low-quality pic");
		}
		defaultModalSizeRect = CGRectMake(CGFloat(50 * DeviceGeneral.scrRatio) , ((DeviceGeneral.scrSize?.height)! - CGFloat(480 * DeviceGeneral.scrRatio)) / 2 , (DeviceGeneral.scrSize?.width)! - CGFloat(100 * DeviceGeneral.scrRatio), CGFloat(480 * DeviceGeneral.scrRatio));
		
    }
    
}