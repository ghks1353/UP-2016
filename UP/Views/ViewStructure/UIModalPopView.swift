//
//  UIModalPopView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 9..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UIModalPopView:UPUIViewController {
	
	func viewDidLoad( title:String ) {
		super.viewDidLoad()
		
		// ModalView
		self.view.backgroundColor = UIColor.white
		self.title = title
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navLeftPadding.width = -12 //Button left padding
		let navCloseButton:UIButton = UIButton() //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState())
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navCloseButton.addTarget(self, action: #selector(self.popToRootAction), for: .touchUpInside)
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ]
		self.navigationItem.hidesBackButton = true  //뒤로 버튼을 커스텀했기 때문에, 가림
		
	} ////////// end initial func
	
	
	///////////////////////////
	func popToRootAction() {
		//Pop to root by back button
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
} ///end class
