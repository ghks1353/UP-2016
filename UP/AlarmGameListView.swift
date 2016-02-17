//
//  AlarmGameListView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class AlarmGameListView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmGameListView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Plain);
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmGameListView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmGame");
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		print("Table wid", DeviceGeneral.defaultModalSizeRect.width)
		
		//add game cell
		var alarmGameListsTableArray:Array<UITableViewCell> = [];
		for (var i:Int = 0; i < UPAlarmGameLists.list.count; ++i) {
			alarmGameListsTableArray += [ createCell(UPAlarmGameLists.list[i]) ];
		}
		tablesArray = [ alarmGameListsTableArray ];
		
		tableView.separatorStyle = .None;
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	///// for table func
	func cellFunc( cellSoundInfoObj:GameInfoObj ) {
		//AddAlarmView.selfView!.setSoundElement(cellSoundInfoObj);
		//AddAlarmView.selfView!.navigationCtrl.popToRootViewControllerAnimated(true);
		
		
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 170;
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	
	
	//Tableview cell view create
	func createCell( gameObj:GameInfoObj ) -> UPGamesListCell {
		let tCell:UPGamesListCell = UPGamesListCell();
		tCell.backgroundColor = gameObj.gameBackgroundUIColor;
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 170); //default cell size
		
		let gameID:Int = UPAlarmGameLists.getGameIDWithObject(gameObj);
		var gameImgName:String = ""; var gameBackgroundImageName:String = "";
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"));
		tGameThumbnailsPictureBackground.frame = CGRectMake(14, 14, 66, 66);
		tCell.addSubview(tGameThumbnailsPictureBackground);
		
		switch(gameID) { //gameid thumbnail show
			case 0:
				gameImgName = "game-thumb-sample-2.png";
				gameBackgroundImageName = "game-background-sample-2.png";
				break;
			default:
				gameImgName = "game-thumb-sample.png";
				break;
		}
		
		let tGameThumbnailsPicture:UIImageView = UIImageView(image: UIImage(named: gameImgName));
		tGameThumbnailsPicture.frame = CGRectMake(14, 14, 66, 66); tCell.addSubview(tGameThumbnailsPicture);
		if (gameBackgroundImageName != "") {
			let tGameBackgroundPicture:UIImageView = UIImageView(image: UIImage(named: gameBackgroundImageName));
			tGameBackgroundPicture.frame = CGRectMake(0, tCell.frame.height - 72.8, tableView.frame.width, 72.8); tCell.addSubview(tGameBackgroundPicture);
		}
		
		///////
		let tGameSubjectLabel:UILabel = UILabel(); //게임 제목
		tGameSubjectLabel.frame = CGRectMake(92, 12, tableView.frame.width * 0.6, 28);
		tGameSubjectLabel.font = UIFont.systemFontOfSize(22);
		tGameSubjectLabel.text = gameObj.gameLangName;
		tGameSubjectLabel.textColor = gameObj.gameTextUIColor;
		let tGameGenreLabel:UILabel = UILabel(); //게임 장르
		tGameGenreLabel.frame = CGRectMake(92, 39, tableView.frame.width * 0.6, 20);
		tGameGenreLabel.font = UIFont.systemFontOfSize(14);
		tGameGenreLabel.text = "# " + gameObj.gameLangGenre;
		tGameGenreLabel.textColor = gameObj.gameTextUIColor;
		
		var gameDifficultyLevelStr:String = "";
		for (var i:Int = 0; i < 5; ++i) {
			gameDifficultyLevelStr += i < gameObj.gameDifficulty ? "★" : "☆";
		}
		
		let tGameDifficultyLabel:UILabel = UILabel(); //게임 난이도
		tGameDifficultyLabel.frame = CGRectMake(92, 58, tableView.frame.width * 0.6, 20);
		tGameDifficultyLabel.font = UIFont.systemFontOfSize(14);
		tGameDifficultyLabel.text = Languages.$("alarmGameDifficulty") + " " + gameDifficultyLevelStr;
		tGameDifficultyLabel.textColor = gameObj.gameTextUIColor;
		
		let tGameDescriptionLabel:UILabel = UILabel();
		tGameDescriptionLabel.frame = CGRectMake(14, 86, tableView.frame.width - 28, 42);
		tGameDescriptionLabel.font = UIFont.systemFontOfSize(14);
		tGameDescriptionLabel.lineBreakMode = .ByCharWrapping;
		tGameDescriptionLabel.numberOfLines = 0;
		tGameDescriptionLabel.text = gameObj.gameLangDescription;
		tGameDescriptionLabel.textColor = gameObj.gameTextUIColor;
		
		tCell.gameInfoObj = gameObj;
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel); tCell.addSubview(tGameDifficultyLabel);
		tCell.addSubview(tGameDescriptionLabel);
		
		return tCell;
	}
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
}