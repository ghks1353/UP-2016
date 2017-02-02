//
//  UIOverlayGuideView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 3..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UIOverlayGuideView:UIViewController {
	
	var guideCloseUIImage:UIImageView = UIImageView()
	var guideCloseUILabel:UILabel = UILabel()
	
	override func viewDidLoad() {
		self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		self.modalTransitionStyle = .crossDissolve
		
		//이미지 설정
		guideCloseUIImage.image = UIImage( named: "comp-guideclose-icon.png" )
		guideCloseUILabel.textAlignment = .right
		guideCloseUILabel.textColor = UIColor.white
		guideCloseUILabel.font = UIFont.systemFont(ofSize: 18)
		guideCloseUILabel.text = LanguagesManager.$("generalClose")
		
		//add views
		self.view.addSubview(guideCloseUIImage)
		self.view.addSubview(guideCloseUILabel)
		
		//Add close touch func
		let tGesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(UIOverlayGuideView.closeGuideView(_:)));
		guideCloseUIImage.isUserInteractionEnabled = true
		guideCloseUIImage.addGestureRecognizer(tGesture)
		
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		//프레임 설정
		fitFrames()
	} // end func
	
	func closeGuideView(_ gst: UITapGestureRecognizer) {
		self.dismiss(animated: true, completion: nil)
	} //end func
	
	//////////
	func fitFrames() {
		guideCloseUIImage.frame = CGRect( x: DeviceManager.scrSize!.width - ((50.5 + 18) * DeviceManager.maxScrRatioC), y: 34 * DeviceManager.maxScrRatioC, width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
		guideCloseUILabel.frame = CGRect( x: guideCloseUIImage.frame.maxX - ((120 + 8) * DeviceManager.maxScrRatioC), y: guideCloseUIImage.frame.maxY + (6 * DeviceManager.maxScrRatioC), width: 120 * DeviceManager.maxScrRatioC, height: 24 )
		
	} //end func
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	} //end func
	
	
}
