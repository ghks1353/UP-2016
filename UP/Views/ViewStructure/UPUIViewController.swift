//
//  UPUIViewController.swift
//  UP
//
//  Created by ExFl on 2017. 8. 12..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UPUIViewController:UIViewController {
	
	//////// Show alert
	func alert( title:String, subject:String = "", promptTitle:String = "", callback:(() -> Void)? = nil ) {
		let fixedConfirm:String = promptTitle == "" ? LanguagesManager.$("generalOK") : promptTitle
		
		let alertController:UIAlertController = UIAlertController(title: title, message: subject, preferredStyle: .alert)
		alertController.addAction( UIAlertAction(title: fixedConfirm, style: .default, handler: { (_) in
			if (callback != nil) {
				callback!()
			} //end if
		}) ) //end addaction
		
		self.present(alertController, animated: true, completion: nil)
	} //end func
	
	func alert( cTitle:String, subject:String = "", confirmTitle:String = "", cancelTitle:String = "", confirmCallback:(() -> Void)? = nil, cancelCallback:(() -> Void)? = nil ) {
		let fixedConfirm:String = confirmTitle == "" ? LanguagesManager.$("generalOK") : confirmTitle
		let fixedCancel:String = cancelTitle == "" ? LanguagesManager.$("generalCancel") : cancelTitle
		
		let alertController:UIAlertController = UIAlertController(title: cTitle, message: subject, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: fixedConfirm, style: .default, handler: { (action) in
			confirmCallback?()
		})) // end act
		alertController.addAction(UIAlertAction(title: fixedCancel, style: .cancel, handler: { (action) in
			cancelCallback?()
		})) // end act
		self.present(alertController, animated: true, completion: nil)
	} // end func
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}
