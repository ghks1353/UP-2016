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
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Plain);
	var tablesArray:Array<AnyObject> = [];
	var achievementsCell:Array<UPAchievementsCell> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		CharacterAchievementsView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("achievements");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AlarmGameListView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		//background add
		let achievementBackground:UIImageView = UIImageView( image: UIImage( named: "modal-background-characterinfo-blank.png" ));
		achievementBackground.frame = CGRectMake( 0, 0, DeviceManager.defaultModalSizeRect.width, DeviceManager.defaultModalSizeRect.height );
		//self.view.addSubview(achievementBackground);
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceManager.defaultModalSizeRect.width, DeviceManager.defaultModalSizeRect.height);
		tableView.backgroundView = achievementBackground;
		self.view.addSubview(tableView);
		
		//도전과제 추가
		for i:Int in 0 ..< AchievementManager.achievementList.count {
			achievementsCell += [ createAchievementCell(i) ];
		}
		
		tablesArray = [ achievementsCell ];
		
		tableView.separatorStyle = .None;
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UIColor.clearColor();
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//table sel evt
		//let currCell:UPAchievementsCell = tableView.cellForRowAtIndexPath(indexPath) as! UPAchievementsCell;
		
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 86.4 + 8;
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 4;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 0));
		headerView.backgroundColor = UIColor.clearColor()
		return headerView
	}
	
	//////////////////////////
	func createAchievementCell( achievementIndex:Int ) -> UPAchievementsCell {
		let achievementCell:UPAchievementsCell = UPAchievementsCell();
		achievementCell.backgroundColor = UIColor.clearColor();
		
		//BG
		let achievementItemBackground:UIImageView = UIImageView();
		
		//클리어 여부에 따라 배경이 좀 다름
		if ( AchievementManager.achievementList[achievementIndex].isCleared ) {
			achievementItemBackground.image = UIImage( named: "achievements-item.png" );
		} else {
			achievementItemBackground.image = UIImage( named: "achievements-item-disabled.png" );
		}
		
		achievementItemBackground.frame = CGRectMake( 9, 4, tableView.frame.width - 18, 86.4 /* <- 조정 필요할수도 있음 */ );
		//Icon
		let achievementItemIcon:UIImageView = UIImageView();
		achievementItemIcon.image = UIImage( named: AchievementManager.getIconNameFromID( AchievementManager.achievementList[achievementIndex].id ) );
		achievementItemIcon.frame = CGRectMake( 9 + 8, (86.4 - 66.66) / 2 + 4, 66.6, 66.6 );
		
		//Achievement Text
		let aText:UILabel = UILabel();
		let aDescription:UILabel = UILabel();
		
		aText.frame = CGRectMake(achievementItemIcon.frame.maxX + 8, achievementItemIcon.frame.minY + 4,
		                         achievementItemBackground.frame.width - (achievementItemIcon.frame.maxX + 8), 24);
		aText.font = UIFont.systemFontOfSize(20); aDescription.font = UIFont.systemFontOfSize(14);
		
		aText.textColor = UIColor.whiteColor();
		aDescription.textColor = UIColor.whiteColor();
		
		aDescription.frame = CGRectMake(aText.frame.minX, aText.frame.maxY,
		                         aText.frame.width, 40);
		
		aDescription.lineBreakMode = .ByCharWrapping;
		aDescription.numberOfLines = 0;
		
		
		//숨겨진 목표의 경우
		if (AchievementManager.achievementList[achievementIndex].isHiddenTitle == true) {
			aText.text = Languages.$("hiddenAchieveTitle");
		} else {
			aText.text = AchievementManager.achievementList[achievementIndex].name;
		}
		if (AchievementManager.achievementList[achievementIndex].isHiddenDescription == true) {
			aDescription.text = Languages.$("hiddenAchieveDescription");
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
