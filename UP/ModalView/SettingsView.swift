//
//  SettingsView.swift
//  	
//
//  Created by ExFl on 2016. 1. 28..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import QuartzCore;

class SettingsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
    
    var settingsArray:Array<SettingsElement> = [];
    var tablesArray:Array<AnyObject> = [];
	
	///////// Test experiments views
	var experimentAlarmSettingsView:ExperimentsAlarmsSetupView = ExperimentsAlarmsSetupView();
	var experimentTestingInfoView:ExperimentsTestInfo = ExperimentsTestInfo();
	/////
	
	/// InSettings Views
	var creditsView:CreditsPopView = CreditsPopView();
	var indieGamesView:IndieGamesView = IndieGamesView();
	var languagesView:LanguageSetupView = LanguageSetupView();
	
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = .clearColor()
		
		//ModalView
        modalView.view.backgroundColor = UIColor.whiteColor();
		modalView.view.frame = DeviceManager.defaultModalSizeRect;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("settingsMenu"); //Modal title
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(SettingsView.viewCloseAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		///////// Nav items fin
		
		//Nvctrl add
		self.view.addSubview(navigationCtrl.view);
		
        //add table to modal
        tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
        modalView.view.addSubview(tableView);
        
        //add table cells (options)
        tablesArray = [
            [ /* SECTION 1 */
				createSettingsToggle( Languages.$("settingsIconBadgeSetting"), defaultState: false, settingsID: "showIconBadge")
				, createSettingsToggle( Languages.$("settingsiCloud"), defaultState: false, settingsID: "syncToiCloud")
				, createSettingsOnlyLabel( Languages.$("settingsChangeLanguage"), menuID: "languageChange")
            ],
            [ /* SECTION 2*/
				createSettingsOnlyLabel( Languages.$("settingsBuyPremium") , menuID: "buyUP")
				, createSettingsOnlyLabel( Languages.$("settingsRestoreBought") , menuID: "restorePurchases")
				, createSettingsOnlyLabel( Languages.$("settingsCoupon") , menuID: "useCoupon")
			],
            [ /* SECTION 3*/
                createSettingsOnlyLabel( Languages.$("settingsStartingGuide") , menuID: "startGuide")
                , createSettingsOnlyLabel( Languages.$("settingsRatingApp") , menuID: "ratingApplication")
                , createSettingsOnlyLabel( Languages.$("settingsShowNewgame") , menuID: "indieGames")
                , createSettingsOnlyLabel( Languages.$("settingsGotoUPProject") , menuID: "gotoUPProject")
				, createSettingsOnlyLabel( Languages.$("settingsCredits") , menuID: "credits")
            ],
            [ /* SECTION 4 */
				createSettingsOnlyLabel( Languages.$("settingsExperimentsAlarm"), menuID: "experiments-notallowed-alarms"),
				createSettingsOnlyLabel( "Technical info", menuID: "experiments-test-info")
			]
            
        ];
        tableView.delegate = self; tableView.dataSource = self;
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
        
        //get data from local
		DataManager.initDefaults();
		var tmpOption:Bool = DataManager.nsDefaults.boolForKey(DataManager.settingsKeys.showBadge);
		if (tmpOption == true) { /* badge option is true? */
			setSwitchData("showIconBadge", value: true);
		}
		//icloud chk
		tmpOption = DataManager.nsDefaults.boolForKey(DataManager.settingsKeys.syncToiCloud);
		if (tmpOption == true) { /* icloud option is true? */
			setSwitchData("syncToiCloud", value: true);
		}
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = modalView.view.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
	}
	
	/////// View transition animation
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//iCloud 가능 여부에 따른 설정 활성/비활성
		setSwitchEnabled("syncToiCloud", value: DataManager.iCloudAvailable);
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_SETTINGS);
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
	
	func setSwitchData(settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).on = true;
				print("Saved data is on:", settingsArray[i].settingsID);
				break;
			}
		} //end for
	}
	func setSwitchEnabled(settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).enabled = value;
				break;
			}
		} //end for
	}
	
	
    /// table setup
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell:CustomTableCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell;
		//element touch handler
		
		switch (cell.cellID) {
			case "buyUP":
				if (PurchaseManager.checkIsAvailableProduct( PurchaseManager.productIDs.PREMIUM ) == false ) {
					print("Buy up is not available");
					showProductNotAvailable();
				} else {
					PurchaseManager.requestBuyProduct( PurchaseManager.productIDs.PREMIUM );
				}
				
				break;
			case "startGuide":
				self.presentViewController(GlobalSubView.startingGuideView, animated: true, completion: nil);
				break;
			case "gotoUPProject":
				UIApplication.sharedApplication().openURL(NSURL(string: "https://up.avngraphic.kr/?l=" + Languages.currentLocaleCode)!);
				break;
			case "languageChange":
				navigationCtrl.pushViewController(self.languagesView, animated: true);
				break;
			case "indieGames":
				navigationCtrl.pushViewController(self.indieGamesView, animated: true);
				break;
			case "credits":
				navigationCtrl.pushViewController(self.creditsView, animated: true);
				creditsView.creditsScrollView.setContentOffset(CGPointMake(0, 0), animated: false);
				break;
			////// EXPERIMENTS
			case "experiments-notallowed-alarms":
				navigationCtrl.pushViewController(self.experimentAlarmSettingsView, animated: true);
				break;
			case "experiments-test-info":
				navigationCtrl.pushViewController(self.experimentTestingInfoView, animated: true);
				break;
			////////
			default: break;
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	} //end func
	
	/////////////////
	
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
            case 0:
                return Languages.$("generalSettings");
			case 1:
				return Languages.$("generalBuySettings");
            case 2:
                return Languages.$("generalGuide");
			case 3: //DEV, TEST
				return Languages.$("settingsExperiments");
            default:
                return "-";
        }
    }
	func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch(section) {
			//case 3: //DEV, TEST
			//	return "주의: 실험실에 있는 내용은 소리없이 추가되거나 삭제될 수 있습니다.";
			default:
				return "";
		}
	}
	
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tablesArray[section] as! Array<AnyObject>).count;
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		return UITableViewAutomaticDimension;
		
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
        return cell;
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38;
    }
    
    ////////////////
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.maskView != nil) {
			self.view.maskView!.frame = DeviceManager.defaultModalSizeRect;
		}
	}
	
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewCloseAction() {
		//Save changes
		saveChasngesToSystem();
		
		ViewController.viewSelf!.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
    }
	
	func saveChasngesToSystem() {
		for i:Int in 0 ..< settingsArray.count {
			switch(settingsArray[i].settingsID) {
				case "showIconBadge":
					DataManager.nsDefaults.setBool((settingsArray[i].settingsElement as! UISwitch).on, forKey: DataManager.settingsKeys.showBadge);
					break;
				case "syncToiCloud":
					DataManager.nsDefaults.setBool((settingsArray[i].settingsElement as! UISwitch).on, forKey: DataManager.settingsKeys.syncToiCloud);
					if ((settingsArray[i].settingsElement as! UISwitch).on == true) {
						print("Settings-Changed iCloud vals");
						DataManager.loadiCloudDefaults();
					}
					break;
				default: //잉어킹: 잉어.. 잉어!! 그러나 아무 일도 일어나지 않았다
					break;
			}
		}
		
		DataManager.save();
	}
	
	func switchChangedEvent( target:UISwitch ) {
		print("switch changed. saving.");
		saveChasngesToSystem();
	}
	
    //Tableview cell view create
    func createSettingsToggle(name:String, defaultState:Bool, settingsID:String ) -> CustomTableCell {
        let tCell:CustomTableCell = CustomTableCell();
        let tLabel:UILabel = UILabel(); let tSwitch:UISwitch = UISwitch();
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		switch(settingsID) { //특정 조건으로 아이콘 구분
			case "showIconBadge": tIconFileStr = "comp-icons-settings-badge"; break;
			case "syncToiCloud": tIconFileStr = "comp-icons-settings-icloud"; break;
			default:
				if (settingsID.rangeOfString("experiments-") != nil) {
					//실험실 아이콘?
					tIconFileStr = "comp-icons-settings-experiments";
				} else {
					tIconFileStr = "comp-icons-blank";
				}
			break;
		}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
        let settingsObj:SettingsElement = SettingsElement();
        settingsObj.settingsID = settingsID; tCell.cellID = settingsID;
        settingsObj.settingsElement = tSwitch; //Anyobject
        
        //해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
        tLabel.frame = CGRectMake(tIconWPadding, 0, self.modalView.view.frame.width * 0.6, 45);
        tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45 /*CGFloat(45 * maxDeviceGeneral.scrRatio)*/ );
        tCell.backgroundColor = UIColor.whiteColor();
		
        tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - 8;
        tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
        //tSwitch.selected = defaultState;
        
        tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
		
		tSwitch.addTarget(self, action: #selector(SettingsView.switchChangedEvent(_:)), forControlEvents: .ValueChanged);
		
        tLabel.text = name;
		tLabel.font = UIFont.systemFontOfSize(16);
		
        //push to settingselement
        settingsArray += [settingsObj];
        
        return tCell;
    }
	
    func createSettingsOnlyLabel(name:String, menuID:String ) -> CustomTableCell {
        let tCell:CustomTableCell = CustomTableCell();
        let tLabel:UILabel = UILabel();
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		switch(menuID) { //특정 조건으로 아이콘 구분
			case "startGuide": tIconFileStr = "comp-icons-settings-guide"; break;
			case "ratingApplication": tIconFileStr = "comp-icons-settings-rating"; break;
			case "indieGames": tIconFileStr = "comp-icons-settings-newgames"; break;
			case "credits": tIconFileStr = "comp-icons-settings-developers"; break;
			case "gotoUPProject": tIconFileStr = "comp-icons-settings-projectup"; break;
			case "languageChange": tIconFileStr = "comp-icons-settings-language"; break;
			
			case "buyUP": tIconFileStr = "comp-icons-shop-buy"; break;
			case "restorePurchases": tIconFileStr = "comp-icons-shop-restore"; break;
			default:
				if (menuID.rangeOfString("experiments-") != nil) {
					//실험실 아이콘?
					
					switch(menuID) {
						case "experiments-notallowed-alarms": tIconFileStr = "comp-icons-settings-experiments-alarm"; break;
						default: tIconFileStr = "comp-icons-settings-experiments"; break;
					}
				} else {
					tIconFileStr = "comp-icons-blank";
				}
				break;
		}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
        let settingsObj:SettingsElement = SettingsElement();
        settingsObj.settingsID = menuID; tCell.cellID = menuID;
        settingsObj.settingsElement = nil; //Anyobject
        
        //해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
        tLabel.frame = CGRectMake(tIconWPadding, 0, self.modalView.view.frame.width, 45);
        tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45);
        tCell.backgroundColor = UIColor.whiteColor();
        
        tCell.addSubview(tLabel);
        tLabel.text = name;
        //tCell.selectionStyle = UITableViewCellSelectionStyle.None;
        tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        tLabel.font = UIFont.systemFontOfSize(16);
        
        settingsArray += [settingsObj];
        
        return tCell;
    }
	
	////////////////
	
	func showProductNotAvailable() {
		let alertWindow:UIAlertController = UIAlertController(title: Languages.$("generalAlert"), message: Languages.$("storeBuyNotAvailable"), preferredStyle: UIAlertControllerStyle.Alert);
		alertWindow.addAction(UIAlertAction(title: Languages.$("generalOK"), style: .Default, handler: { (action: UIAlertAction!) in
		}));
		presentViewController(alertWindow, animated: true, completion: nil);
		
	} //end function
	
}