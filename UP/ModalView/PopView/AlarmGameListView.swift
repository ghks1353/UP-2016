//
//  AlarmGameListView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class AlarmGameListView:UIModalPopView, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmGameListView?
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.plain)
	var tablesArray:Array<AnyObject> = []
	var alarmGameListsTableArray:Array<UPGamesListCell> = []
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("alarmGame") )
		AlarmGameListView.selfView = self
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height)
		self.view.addSubview(tableView)
		
		//add game cell
		alarmGameListsTableArray += [ createRandomCell() ] //ADD random cell
		for i:Int in 0 ..< GameManager.list.count {
			alarmGameListsTableArray += [ createCell(GameManager.list[i]) ]
		} ////end for
		tablesArray = [ alarmGameListsTableArray as AnyObject ]
		
		tableView.separatorStyle = .none
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
	} //end func
	
	///////////////////////////////////
	func selectCell( _ gameID:Int ) {
		//unselect all
		//fuckiug swift 3.0
		var gameIDvar:Int = gameID
		gameIDvar = gameIDvar + 1
		
		for i:Int in 0 ..< alarmGameListsTableArray.count {
			alarmGameListsTableArray[i].gameCheckImageView!.alpha = 0
		} //end for
		
		//Check it
		alarmGameListsTableArray[gameIDvar].gameCheckImageView!.alpha = 1
	} //end func
	
	///////////////////////////////////
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//table sel evt
		let currCell:UPGamesListCell = tableView.cellForRow(at: indexPath) as! UPGamesListCell
		AddAlarmView.selfView!.setGameElement( currCell.gameID )
		
		selectCell( currCell.gameID )
		tableView.deselectRow(at: indexPath, animated: true)
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if ((indexPath as NSIndexPath).row == 0) {
			return 95
		} //end if
		return 140
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] as! Array<AnyObject>)[(indexPath as NSIndexPath).row] as! UITableViewCell
		return cell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0
	} ////////////////////////////////////
	
	//Random select cell
	func createRandomCell() -> UPGamesListCell {
		let tCell:UPGamesListCell = UPGamesListCell()
		tCell.backgroundColor = UPUtils.colorWithHexString("#333333")
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 95)
		
		//Random game
		let gameImgName:String = "game-thumb-random.png"
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"))
		tGameThumbnailsPictureBackground.frame = CGRect(x: 14, y: 14, width: 66, height: 66)
		tCell.addSubview(tGameThumbnailsPictureBackground)
		
		let tGameThumbnailsPicture:UIImageView = UIImageView(image: UIImage(named: gameImgName))
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame
		tCell.addSubview(tGameThumbnailsPicture)
		
		let tGameCheckPic:UIImageView = UIImageView(image: UIImage(named: "game-thumbs-check.png"))
		tGameCheckPic.frame = tGameThumbnailsPictureBackground.frame
		tCell.addSubview(tGameCheckPic)
		
		///////
		let tGameSubjectLabel:UILabel = UILabel() //게임 제목
		tGameSubjectLabel.frame = CGRect(x: 92, y: 22, width: tableView.frame.width * 0.6, height: 28)
		tGameSubjectLabel.font = UIFont.systemFont(ofSize: 22)
		tGameSubjectLabel.text = LanguagesManager.$("alarmGameRandom") //Random
		tGameSubjectLabel.textColor = UIColor.white
		
		let tGameGenreLabel:UILabel = UILabel() //게임 장르
		tGameGenreLabel.frame = CGRect(x: 92, y: 49, width: tableView.frame.width * 0.6, height: 20)
		tGameGenreLabel.font = UIFont.systemFont(ofSize: 14)
		tGameGenreLabel.text = "# ?"
		tGameGenreLabel.textColor = UIColor.white
		
		////////////////
		tCell.gameID = -1
		tCell.gameCheckImageView = tGameCheckPic
		tCell.addSubview(tGameSubjectLabel)
		tCell.addSubview(tGameGenreLabel)
		
		return tCell
	} ///// end func
	
	//////////////////////////////////////////////////////////
	//Tableview cell view create
	func createCell( _ gameObj:GameData ) -> UPGamesListCell {
		let tCell:UPGamesListCell = UPGamesListCell()
		tCell.backgroundColor = gameObj.gameBackgroundUIColor
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 140) //default cell size
		
		let gameID:Int = GameManager.getGameIDWithObject(gameObj)
		var gameImgName:String = ""
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"))
		tGameThumbnailsPictureBackground.frame = CGRect(x: 14, y: 14, width: 66, height: 66)
		tCell.addSubview(tGameThumbnailsPictureBackground)
		
		//Get thumb from manager
		gameImgName = GameManager.getThumbnailWithGameID(gameID)
		
		//게임 섬네일, 체크박스 이미지뷰
		let tGameThumbnailsPicture:UIImageView = UIImageView(image: UIImage(named: gameImgName))
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame; tCell.addSubview(tGameThumbnailsPicture)
		
		let tGameCheckPic:UIImageView = UIImageView(image: UIImage(named: "game-thumbs-check.png"))
		tGameCheckPic.frame = tGameThumbnailsPictureBackground.frame
		tCell.addSubview(tGameCheckPic)
		
		/////////////////////
		let tGameSubjectLabel:UILabel = UILabel() //게임 제목
		tGameSubjectLabel.frame = CGRect(x: 92, y: 12, width: tableView.frame.width * 0.6, height: 28)
		tGameSubjectLabel.font = UIFont.systemFont(ofSize: 22)
		tGameSubjectLabel.text = gameObj.gameLangName
		tGameSubjectLabel.textColor = gameObj.gameTextUIColor
		let tGameGenreLabel:UILabel = UILabel() //게임 장르
		tGameGenreLabel.frame = CGRect(x: 92, y: 39, width: tableView.frame.width * 0.6, height: 20)
		tGameGenreLabel.font = UIFont.systemFont(ofSize: 14)
		tGameGenreLabel.text = "# " + gameObj.gameLangGenre
		tGameGenreLabel.textColor = gameObj.gameTextUIColor
		
		var gameDifficultyLevelStr:String = ""
		for i:Int in 0 ..< 5 {
			gameDifficultyLevelStr += i < gameObj.gameDifficulty ? "★" : "☆"
		} //end for
		
		let tGameDifficultyLabel:UILabel = UILabel() //게임 난이도
		tGameDifficultyLabel.frame = CGRect(x: 92, y: 58, width: tableView.frame.width * 0.6, height: 20)
		tGameDifficultyLabel.font = UIFont.systemFont(ofSize: 14)
		tGameDifficultyLabel.text = LanguagesManager.$("alarmGameDifficulty") + " " + gameDifficultyLevelStr
		tGameDifficultyLabel.textColor = gameObj.gameTextUIColor
		
		let tGameDescriptionLabel:UILabel = UILabel()
		tGameDescriptionLabel.frame = CGRect(x: 14, y: 86, width: tableView.frame.width - 28, height: 42)
		tGameDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
		tGameDescriptionLabel.lineBreakMode = .byCharWrapping
		tGameDescriptionLabel.numberOfLines = 0
		tGameDescriptionLabel.text = gameObj.gameLangDescription
		tGameDescriptionLabel.textColor = gameObj.gameTextUIColor
		
		tCell.gameID = gameID
		tCell.gameCheckImageView = tGameCheckPic
		tCell.gameInfoObj = gameObj
		tCell.addSubview(tGameSubjectLabel)
		tCell.addSubview(tGameGenreLabel)
		tCell.addSubview(tGameDifficultyLabel)
		tCell.addSubview(tGameDescriptionLabel)
		
		return tCell
	} /// end func
	
	//UITextfield del
	func textFieldShouldReturn(_ textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	} //end func
	
	
}
