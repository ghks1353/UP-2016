//
//  GamePlayView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 28..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class GamePlayView:UIModalView, UITableViewDataSource, UITableViewDelegate {
	
	//for access
	static var selfView:GamePlayView?
	
	//Table for menu
	var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.plain)
	var tablesArray:Array<AnyObject> = []
	var alarmGameListsTableArray:Array<UPGamesListCell> = []
	
	 //게임하기 플레이창.
	var modalGamePlayWindowView:GamePlayWindowView = GlobalSubView.alarmGamePlayWindowView
	
	//modal이 추가로 나올 경우 표시할 오버레이
	var modalOverlayView:UIView = UIView()
	var modalOverlayMaskView:UIView = UIView()
	
	override func viewDidLoad() {
		super.viewDidLoad(LanguagesManager.$("gamePlay"), barColor: UPUtils.colorWithHexString("#333333"))
		
		modalOverlayView.backgroundColor = UIColor.black
		modalOverlayView.isHidden = true
		modalOverlayView.alpha = 0
		self.view.addSubview(modalOverlayView)
		
		GamePlayView.selfView = self
		
		//add table to modal
		tableView.frame = CGRect(x: 0, y: 0, width: modalView.view.frame.width, height: modalView.view.frame.height)
		tableView.separatorStyle = .none
		modalView.view.addSubview(tableView)
		
		//add game cell
		for i:Int in 0 ..< GameManager.list.count {
			alarmGameListsTableArray += [ createCell(GameManager.list[i]) ]
		}
		tablesArray = [ alarmGameListsTableArray as AnyObject ]
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
	} //end init
	
	////////////////
	override func FitModalLocationToCenter() {
		modalOverlayView.frame = CGRect( x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height )
		super.FitModalLocationToCenter()
	}
	///////////////////////////////
	
	func toggleOverlay( _ status:Bool ) {
		let beforeAlpha:CGFloat = status ? 0 : 1
		let afterAlpha:CGFloat = status ? 1 : 0
		
		if (status) {
			modalOverlayView.isHidden = false
		}
		
		modalOverlayView.alpha = beforeAlpha
		UIView.animate(withDuration: 0.36, delay: 0, options: .curveLinear, animations: {
			self.modalOverlayView.alpha = afterAlpha
		}) { _ in
			if (afterAlpha == 0) {
				self.modalOverlayView.isHidden = true
			}
		}
	} //end func
	
	//////////////// tables delg
	internal func selectCell( _ gameID:Int ) {
		toggleOverlay(true)
		modalGamePlayWindowView.modalPresentationStyle = .overFullScreen
		self.present(modalGamePlayWindowView, animated: false, completion: nil)
		modalGamePlayWindowView.setGame( gameID )
	}
	
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//table sel evt
		let currCell:UPGamesListCell = tableView.cellForRow(at: indexPath) as! UPGamesListCell
		
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
	
	//Tableview cell view create
	func createCell( _ gameObj:GameInfoObj ) -> UPGamesListCell {
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
		
		///////
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
		}
		
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
		tCell.gameInfoObj = gameObj
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel); tCell.addSubview(tGameDifficultyLabel);
		tCell.addSubview(tGameDescriptionLabel);
		
		return tCell
	} ///////////////// end func
	//////////////
	
}
