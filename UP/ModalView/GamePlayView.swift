//
//  GamePlayView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 28..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class GamePlayView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//for access
	static var selfView:GamePlayView?;
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Table for menu
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.plain);
	var tablesArray:Array<AnyObject> = [];
	var alarmGameListsTableArray:Array<UPGamesListCell> = [];
	
	var modalGamePlayWindowView:GamePlayWindowView = GlobalSubView.alarmGamePlayWindowView; //게임하기 플레이창.
	
	//modal이 추가로 나올 경우 표시할 오버레이
	var modalOverlayView:UIView = UIView();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = UIColor.clear;
		
		GamePlayView.selfView = self;
		
		//ModalView
		modalView.view.backgroundColor = UIColor.white;
		modalView.view.frame = DeviceManager.defaultModalSizeRect;
		
		//Modal overlay view
		modalOverlayView.backgroundColor = UIColor.black;
		modalOverlayView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		modalOverlayView.isHidden = true; modalOverlayView.alpha = 0;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("gamePlay");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(GamePlayView.viewCloseAction), for: .touchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		
		///////// Nav items fin
		
		//Add Ctrl vw
		self.view.addSubview(navigationCtrl.view);
		self.view.addSubview(modalOverlayView);
		
		//add table to modal
		tableView.frame = CGRect(x: 0, y: 0, width: modalView.view.frame.width, height: modalView.view.frame.height);
		tableView.separatorStyle = .none;
		modalView.view.addSubview(tableView);
		
		//add game cell
		for i:Int in 0 ..< GameManager.list.count {
			alarmGameListsTableArray += [ createCell(GameManager.list[i]) ];
		}
		tablesArray = [ alarmGameListsTableArray as AnyObject ];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = CGRect(x: 0, y: 0, width: navigationCtrl.view.frame.width, height: navigationCtrl.view.frame.height);
		modalMaskImageView.contentMode = .scaleAspectFit; navigationCtrl.view.mask = modalMaskImageView;
		
		FitModalLocationToCenter();
	}
	
	////////////////
	
	func FitModalLocationToCenter() {
		modalOverlayView.frame = CGRect( x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height );
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.mask != nil) {
			navigationCtrl.view.mask!.frame = CGRect(x: 0, y: 0, width: navigationCtrl.view.frame.width, height: navigationCtrl.view.frame.height);
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning();
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismiss(animated: true, completion: nil);
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
		                             width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.view.frame = CGRect(x: 0, y: 0,
				width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	func toggleOverlay( _ status:Bool ) {
		var beforeAlpha:CGFloat = 0; var afterAlpha:CGFloat = 0;
		if (status) {
			modalOverlayView.isHidden = false; beforeAlpha = 0; afterAlpha = 1; //modalOverlayView.alpha = 1;
		} else {
			beforeAlpha = 1; afterAlpha = 0; //modalOverlayView.alpha = 0;
		}
		
		modalOverlayView.alpha = beforeAlpha;
		UIView.animate(withDuration: 0.36, delay: 0, options: .curveLinear, animations: {
			self.modalOverlayView.alpha = afterAlpha;
		}) { _ in
			if (afterAlpha == 0) {
				self.modalOverlayView.isHidden = true;
			}
		}
	}
	
	//////////////// tables delg
	internal func selectCell( _ gameID:Int ) {
		toggleOverlay(true);
		modalGamePlayWindowView.modalPresentationStyle = .overFullScreen;
		self.present(modalGamePlayWindowView, animated: false, completion: nil);
		modalGamePlayWindowView.setGame( gameID );
		
	}
	
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//table sel evt
		let currCell:UPGamesListCell = tableView.cellForRow(at: indexPath) as! UPGamesListCell;
		
		selectCell( currCell.gameID );
		tableView.deselectRow(at: indexPath, animated: true);
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {		
		return 140;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] as! Array<AnyObject>)[(indexPath as NSIndexPath).row] as! UITableViewCell;
		return cell;
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	
	
	//Tableview cell view create
	func createCell( _ gameObj:GameInfoObj ) -> UPGamesListCell {
		let tCell:UPGamesListCell = UPGamesListCell();
		tCell.backgroundColor = gameObj.gameBackgroundUIColor;
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 140); //default cell size
		
		let gameID:Int = GameManager.getGameIDWithObject(gameObj);
		var gameImgName:String = ""; //var gameBackgroundImageName:String = "";
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"));
		tGameThumbnailsPictureBackground.frame = CGRect(x: 14, y: 14, width: 66, height: 66);
		tCell.addSubview(tGameThumbnailsPictureBackground);
		
		//Get thumb from manager
		gameImgName = GameManager.getThumbnailWithGameID(gameID);
		
		//게임 섬네일, 체크박스 이미지뷰
		let tGameThumbnailsPicture:UIImageView = UIImageView(image: UIImage(named: gameImgName));
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame; tCell.addSubview(tGameThumbnailsPicture);
		
		///////
		let tGameSubjectLabel:UILabel = UILabel(); //게임 제목
		tGameSubjectLabel.frame = CGRect(x: 92, y: 12, width: tableView.frame.width * 0.6, height: 28);
		tGameSubjectLabel.font = UIFont.systemFont(ofSize: 22);
		tGameSubjectLabel.text = gameObj.gameLangName;
		tGameSubjectLabel.textColor = gameObj.gameTextUIColor;
		let tGameGenreLabel:UILabel = UILabel(); //게임 장르
		tGameGenreLabel.frame = CGRect(x: 92, y: 39, width: tableView.frame.width * 0.6, height: 20);
		tGameGenreLabel.font = UIFont.systemFont(ofSize: 14);
		tGameGenreLabel.text = "# " + gameObj.gameLangGenre;
		tGameGenreLabel.textColor = gameObj.gameTextUIColor;
		
		var gameDifficultyLevelStr:String = "";
		for i:Int in 0 ..< 5 {
			gameDifficultyLevelStr += i < gameObj.gameDifficulty ? "★" : "☆";
		}
		
		let tGameDifficultyLabel:UILabel = UILabel(); //게임 난이도
		tGameDifficultyLabel.frame = CGRect(x: 92, y: 58, width: tableView.frame.width * 0.6, height: 20);
		tGameDifficultyLabel.font = UIFont.systemFont(ofSize: 14);
		tGameDifficultyLabel.text = Languages.$("alarmGameDifficulty") + " " + gameDifficultyLevelStr;
		tGameDifficultyLabel.textColor = gameObj.gameTextUIColor;
		
		let tGameDescriptionLabel:UILabel = UILabel();
		tGameDescriptionLabel.frame = CGRect(x: 14, y: 86, width: tableView.frame.width - 28, height: 42);
		tGameDescriptionLabel.font = UIFont.systemFont(ofSize: 14);
		tGameDescriptionLabel.lineBreakMode = .byCharWrapping;
		tGameDescriptionLabel.numberOfLines = 0;
		tGameDescriptionLabel.text = gameObj.gameLangDescription;
		tGameDescriptionLabel.textColor = gameObj.gameTextUIColor;
		
		tCell.gameID = gameID;
		tCell.gameInfoObj = gameObj;
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel); tCell.addSubview(tGameDifficultyLabel);
		tCell.addSubview(tGameDescriptionLabel);
		
		return tCell;
	}
	
	
}
