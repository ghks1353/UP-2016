//
//  CharacterAchievementsView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 26..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit;

class CharacterAchievementsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:CharacterAchievementsView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.plain);
	var tablesArray:Array<AnyObject> = [];
	var achievementsCell:Array<UPAchievementsCell> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		CharacterAchievementsView.selfView = self;
		
		self.view.backgroundColor = UIColor.clear;
		
		//ModalView
		self.view.backgroundColor = UIColor.white;
		self.title = LanguagesManager.$("achievements");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(CharacterAchievementsView.popToRootAction), for: .touchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		//background add
		let achievementBackground:UIImageView = UIImageView( image: UIImage( named: "modal-background-characterinfo-blank.png" ));
		achievementBackground.frame = CGRect( x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height );
		//self.view.addSubview(achievementBackground);
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height);
		tableView.backgroundView = achievementBackground;
		self.view.addSubview(tableView);
		
		//도전과제 추가
		for i:Int in 0 ..< AchievementManager.achievementList.count {
			achievementsCell += [ createAchievementCell(i) ];
		}
		
		tablesArray = [ achievementsCell as AnyObject ];
		
		tableView.separatorStyle = .none;
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UIColor.clear;
	}
	
	func popToRootAction() {
		//Pop to root by back button
		ViewController.selfView!.modalCharacterInformationView.fadeInGuideButton( false )
		_ = self.navigationController?.popViewController(animated: true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//table sel evt
		//let currCell:UPAchievementsCell = tableView.cellForRowAtIndexPath(indexPath) as! UPAchievementsCell;
		
		
		tableView.deselectRow(at: indexPath, animated: true);
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86.4 + 8;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] as! Array<AnyObject>)[(indexPath as NSIndexPath).row] as! UITableViewCell;
		return cell;
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 4;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0));
		headerView.backgroundColor = UIColor.clear
		return headerView
	}
	
	//////////////////////////
	func createAchievementCell( _ achievementIndex:Int ) -> UPAchievementsCell {
		let achievementCell:UPAchievementsCell = UPAchievementsCell();
		achievementCell.backgroundColor = UIColor.clear;
		
		//BG
		let achievementItemBackground:UIImageView = UIImageView();
		
		//클리어 여부에 따라 배경이 좀 다름
		if ( AchievementManager.achievementList[achievementIndex].isCleared ) {
			achievementItemBackground.image = UIImage( named: "achievements-item.png" );
		} else {
			achievementItemBackground.image = UIImage( named: "achievements-item-disabled.png" );
		}
		
		achievementItemBackground.frame = CGRect( x: 9, y: 4, width: tableView.frame.width - 18, height: 86.4 /* <- 조정 필요할수도 있음 */ );
		//Icon
		let achievementItemIcon:UIImageView = UIImageView();
		achievementItemIcon.image = UIImage( named: AchievementManager.getIconNameFromID( AchievementManager.achievementList[achievementIndex].id ) );
		achievementItemIcon.frame = CGRect( x: 9 + 8, y: (86.4 - 66.66) / 2 + 4, width: 66.6, height: 66.6 );
		
		//Achievement Text
		let aText:UILabel = UILabel();
		let aDescription:UILabel = UILabel();
		
		aText.frame = CGRect(x: achievementItemIcon.frame.maxX + 8, y: achievementItemIcon.frame.minY + 4,
		                         width: achievementItemBackground.frame.width - (achievementItemIcon.frame.maxX + 8), height: 24);
		aText.font = UIFont.systemFont(ofSize: 20); aDescription.font = UIFont.systemFont(ofSize: 14);
		
		aText.textColor = UIColor.white;
		aDescription.textColor = UIColor.white;
		
		aDescription.frame = CGRect(x: aText.frame.minX, y: aText.frame.maxY,
		                         width: aText.frame.width, height: 40);
		
		aDescription.lineBreakMode = .byCharWrapping;
		aDescription.numberOfLines = 0;
		
		
		//숨겨진 목표의 경우
		if (AchievementManager.achievementList[achievementIndex].isHiddenTitle == true) {
			aText.text = LanguagesManager.$("hiddenAchieveTitle");
		} else {
			aText.text = AchievementManager.achievementList[achievementIndex].name;
		}
		if (AchievementManager.achievementList[achievementIndex].isHiddenDescription == true) {
			aDescription.text = LanguagesManager.$("hiddenAchieveDescription");
		} else {
			aDescription.text = AchievementManager.achievementList[achievementIndex].description;
		}
		
		
		
		//Add to view
		achievementCell.addSubview(achievementItemBackground);
		achievementCell.addSubview(achievementItemIcon);

		achievementCell.addSubview(aText);
		achievementCell.addSubview(aDescription);
		
		return achievementCell;
	}
	
}
