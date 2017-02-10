//
//  CharacterThemeSelectView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 10..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class CharacterThemeSelectView:UIModalPopView {
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("userTheme") )
		
		//background add
		let skinBackground:UIImageView = UIImageView( image: UIImage( named: "themes-select-background.png" ))
		skinBackground.frame = CGRect( x: 0, y: self.navigationController!.navigationBar.frame.size.height, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height - self.navigationController!.navigationBar.frame.size.height)
		self.view.addSubview(skinBackground) //subview for background
		
		
	} /////////// end func
	
	override func viewWillAppear(_ animated: Bool) {
		
	}
	
	///////// select category
	func setThemeCategory( categoryID:Int ) {
		/*
		switch (categoryID) {
			
		}*/
		
	} //end func
	
} //// end class
