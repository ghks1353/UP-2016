//
//  AlarmGameListView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class AlarmGameListView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmGameListView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Plain);
	var tablesArray:Array<AnyObject> = [];
	var alarmGameListsTableArray:Array<UPGamesListCell> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmGameListView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmGame");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AlarmGameListView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		print("Table wid", DeviceGeneral.defaultModalSizeRect.width)
		
		//add game cell
		alarmGameListsTableArray += [ createRandomCell() ]; //ADD random cell
		for i:Int in 0 ..< GameManager.list.count {
			alarmGameListsTableArray += [ createCell(GameManager.list[i]) ];
		}
		tablesArray = [ alarmGameListsTableArray ];
		
		tableView.separatorStyle = .None;
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	internal func selectCell( gameID:Int ) {
		//unselect all
		//fuckiug swift 3.0
		var gameIDvar:Int = gameID;
		gameIDvar = gameIDvar + 1;
		for i:Int in 0 ..< alarmGameListsTableArray.count {
			alarmGameListsTableArray[i].gameCheckImageView!.alpha = 0;
		}
		
		//Check it
		alarmGameListsTableArray[gameIDvar].gameCheckImageView!.alpha = 1;
		
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//table sel evt
		let currCell:UPGamesListCell = tableView.cellForRowAtIndexPath(indexPath) as! UPGamesListCell;
		AddAlarmView.selfView?.setGameElement( currCell.gameID );
		
		selectCell( currCell.gameID );
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		/*let currCell:UPGamesListCell = tableView.cellForRowAtIndexPath(indexPath) as! UPGamesListCell;
		if (currCell.gameID == -1) {
			return 85;
		}*/
		if (indexPath.row == 0) {
			return 95;
		}
		
		return 140;
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
	
	
	//Random select cell
	func createRandomCell() -> UPGamesListCell {
		let tCell:UPGamesListCell = UPGamesListCell();
		tCell.backgroundColor = UPUtils.colorWithHexString("#333333");
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 95);
		
		//Random game
		let gameImgName:String = "game-thumb-random.png";
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"));
		tGameThumbnailsPictureBackground.frame = CGRectMake(14, 14, 66, 66);
		tCell.addSubview(tGameThumbnailsPictureBackground);
		
		let tGameThumbnailsPicture:UIImageView = UIImageView(image: UIImage(named: gameImgName));
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame; tCell.addSubview(tGameThumbnailsPicture);
		
		let tGameCheckPic:UIImageView = UIImageView(image: UIImage(named: "game-thumbs-check.png"));
		tGameCheckPic.frame = tGameThumbnailsPictureBackground.frame;
		tCell.addSubview(tGameCheckPic);
		
		///////
		let tGameSubjectLabel:UILabel = UILabel(); //게임 제목
		tGameSubjectLabel.frame = CGRectMake(92, 22, tableView.frame.width * 0.6, 28);
		tGameSubjectLabel.font = UIFont.systemFontOfSize(22);
		tGameSubjectLabel.text = Languages.$("alarmGameRandom"); //Random
		tGameSubjectLabel.textColor = UIColor.whiteColor();
		
		let tGameGenreLabel:UILabel = UILabel(); //게임 장르
		tGameGenreLabel.frame = CGRectMake(92, 49, tableView.frame.width * 0.6, 20);
		tGameGenreLabel.font = UIFont.systemFontOfSize(14);
		tGameGenreLabel.text = "# ?";
		tGameGenreLabel.textColor = UIColor.whiteColor();
		
		
		tCell.gameID = -1;
		tCell.gameCheckImageView = tGameCheckPic;
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel);
		
		return tCell;
	}
	
	//Tableview cell view create
	func createCell( gameObj:GameInfoObj ) -> UPGamesListCell {
		let tCell:UPGamesListCell = UPGamesListCell();
		tCell.backgroundColor = gameObj.gameBackgroundUIColor;
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 140); //default cell size
		
		let gameID:Int = GameManager.getGameIDWithObject(gameObj);
		var gameImgName:String = ""; //var gameBackgroundImageName:String = "";
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"));
		tGameThumbnailsPictureBackground.frame = CGRectMake(14, 14, 66, 66);
		tCell.addSubview(tGameThumbnailsPictureBackground);
		
		//Get thumb from manager
		gameImgName = GameManager.getThumbnailWithGameID(gameID);
		
		//게임 섬네일, 체크박스 이미지뷰
		let tGameThumbnailsPicture:UIImageView = UIImageView(image: UIImage(named: gameImgName));
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame; tCell.addSubview(tGameThumbnailsPicture);
		let tGameCheckPic:UIImageView = UIImageView(image: UIImage(named: "game-thumbs-check.png"));
		tGameCheckPic.frame = tGameThumbnailsPictureBackground.frame;
		tCell.addSubview(tGameCheckPic);
		
		
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
		for i:Int in 0 ..< 5 {
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
		
		tCell.gameID = gameID;
		tCell.gameCheckImageView = tGameCheckPic;
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