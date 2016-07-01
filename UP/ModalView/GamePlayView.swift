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
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Plain);
	var tablesArray:Array<AnyObject> = [];
	var alarmGameListsTableArray:Array<UPGamesListCell> = [];
	
	var modalGamePlayWindowView:GamePlayWindowView = GlobalSubView.alarmGamePlayWindowView; //게임하기 플레이창.
	
	//modal이 추가로 나올 경우 표시할 오버레이
	var modalOverlayView:UIView = UIView();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		GamePlayView.selfView = self;
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		modalView.view.frame = DeviceManager.defaultModalSizeRect;
		
		//Modal overlay view
		modalOverlayView.backgroundColor = UIColor.blackColor();
		modalOverlayView.frame = CGRectMake(0, 0, DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
		modalOverlayView.hidden = true; modalOverlayView.alpha = 0;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("gamePlay");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(GamePlayView.viewCloseAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		
		///////// Nav items fin
		
		//Add Ctrl vw
		self.view.addSubview(navigationCtrl.view);
		self.view.addSubview(modalOverlayView);
		
		//add table to modal
		tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		tableView.separatorStyle = .None;
		modalView.view.addSubview(tableView);
		
		//add game cell
		for i:Int in 0 ..< GameManager.list.count {
			alarmGameListsTableArray += [ createCell(GameManager.list[i]) ];
		}
		tablesArray = [ alarmGameListsTableArray ];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = CGRectMake(0, 0, navigationCtrl.view.frame.width, navigationCtrl.view.frame.height);
		modalMaskImageView.contentMode = .ScaleAspectFit; navigationCtrl.view.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
	}
	
	////////////////
	
	func FitModalLocationToCenter() {
		modalOverlayView.frame = CGRectMake( 0, 0, DeviceManager.scrSize!.width, DeviceManager.scrSize!.height );
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.maskView != nil) {
			navigationCtrl.view.maskView!.frame = CGRectMake(0, 0, navigationCtrl.view.frame.width, navigationCtrl.view.frame.height);
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning();
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end func
	
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_PLAYGAME);
	}
	
	override func viewWillDisappear(animated: Bool) {
		AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceManager.scrSize!.height,
		                             DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	func toggleOverlay( status:Bool ) {
		var beforeAlpha:CGFloat = 0; var afterAlpha:CGFloat = 0;
		if (status) {
			modalOverlayView.hidden = false; beforeAlpha = 0; afterAlpha = 1; //modalOverlayView.alpha = 1;
		} else {
			beforeAlpha = 1; afterAlpha = 0; //modalOverlayView.alpha = 0;
		}
		
		modalOverlayView.alpha = beforeAlpha;
		UIView.animateWithDuration(0.36, delay: 0, options: .CurveLinear, animations: {
			self.modalOverlayView.alpha = afterAlpha;
		}) { _ in
			if (afterAlpha == 0) {
				self.modalOverlayView.hidden = true;
			}
		}
	}
	
	//////////////// tables delg
	internal func selectCell( gameID:Int ) {
		toggleOverlay(true);
		modalGamePlayWindowView.modalPresentationStyle = .OverFullScreen;
		self.presentViewController(modalGamePlayWindowView, animated: false, completion: nil);
		modalGamePlayWindowView.setGame( gameID );
		
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//table sel evt
		let currCell:UPGamesListCell = tableView.cellForRowAtIndexPath(indexPath) as! UPGamesListCell;
		
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
		tCell.gameInfoObj = gameObj;
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel); tCell.addSubview(tGameDifficultyLabel);
		tCell.addSubview(tGameDescriptionLabel);
		
		return tCell;
	}
	
	
}