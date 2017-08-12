//
//  SettingsView.swift
//  	
//
//  Created by ExFl on 2016. 1. 28..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import StoreKit
import SwiftyStoreKit

class SettingsView:UIModalView, UITableViewDataSource, UITableViewDelegate {
	
	static var selfView:SettingsView?
	
    //Table for menu
	var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
    
    var settingsArray:Array<SettingsElement> = []
    var tablesArray:Array<Array<AnyObject>> = []
	
	///////// 종료하면서 구매 창을 열어야 하는 경우
	var runBuyEXPackModal:Bool = false
	
	///////// Test experiments views
	var experimentAlarmSettingsView:ExperimentsAlarmsSetupView = ExperimentsAlarmsSetupView()
	var experimentTestingInfoView:ExperimentsTestInfo = ExperimentsTestInfo()
	///////////////////////////////////////////
	
	/// InSettings Views
	var creditsView:CreditsPopView = CreditsPopView()
	var indieGamesView:IndieGamesView = IndieGamesView()
	var languagesView:LanguageSetupView = LanguageSetupView()
	
	//// Testers view
	var testersWebView:TestersWebView = TestersWebView()
	
    override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("settingsMenu"), barColor: UPUtils.colorWithHexString("#333333") )
		SettingsView.selfView = self
		
        //add table to modal
        tableView.frame = CGRect(x: 0, y: 0, width: modalView.view.frame.width, height: modalView.view.frame.height)
        modalView.view.addSubview(tableView)
        
        //add table cells (options)
        tablesArray = [
            [ /* SECTION 1 */
				createSettingsToggle( LanguagesManager.$("settingsIconBadgeSetting"), defaultState: false, settingsID: "showIconBadge")
				, createSettingsToggle( LanguagesManager.$("settingsiCloud"), defaultState: false, settingsID: "syncToiCloud")
				, createSettingsOnlyLabel( LanguagesManager.$("settingsChangeLanguage"), menuID: "languageChange")
            ],
           /* [ /* SECTION 2*/
				createSettingsOnlyLabel( LanguagesManager.$("settingsBuyPremium") , menuID: "buyUP")
				, createSettingsOnlyLabel( LanguagesManager.$("settingsRestoreBought") , menuID: "restorePurchases")
				, createSettingsOnlyLabel( LanguagesManager.$("settingsCoupon") , menuID: "useCoupon")
			],*/
            [ /* SECTION 3*/
                createSettingsOnlyLabel( LanguagesManager.$("settingsStartingGuide") , menuID: "startGuide")
                , createSettingsOnlyLabel( LanguagesManager.$("settingsRatingApp") , menuID: "ratingApplication")
                //, createSettingsOnlyLabel( LanguagesManager.$("settingsShowNewgame") , menuID: "indieGames")
				, createSettingsOnlyLabel( LanguagesManager.$("settingsDonate") , menuID: "donateUP")
                , createSettingsOnlyLabel( LanguagesManager.$("settingsGotoUPProject") , menuID: "gotoUPProject")
				, createSettingsOnlyLabel( LanguagesManager.$("settingsCredits") , menuID: "credits")
            ],
            [ /* SECTION 4 */
				createSettingsOnlyLabel( LanguagesManager.$("settingsExperimentsAlarm"), menuID: "experiments-notallowed-alarms")
			],
			[ /* section 5 */
				createSettingsOnlyLabel( "Debug info", menuID: "debug-test-info"),
				createSettingsOnlyLabel( "UP Testers web", menuID: "notice-fortesters")
			] ///////////////////////////////////
        ]
		
		tableView.delegate = self
		tableView.dataSource = self
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
        
        //get data from local for load settings
		DataManager.initDefaults()
		var tmpOption:Bool = DataManager.getSavedDataBool(DataManager.settingsKeys.showBadge)
		if (tmpOption == true) { /* badge option is true? */
			setSwitchData("showIconBadge", value: true)
		}
		//icloud chk
		tmpOption = DataManager.getSavedDataBool(DataManager.settingsKeys.syncToiCloud)
		if (tmpOption == true) { /* icloud option is true? */
			setSwitchData("syncToiCloud", value: true)
		}
	} ////end init func
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		//iCloud 가능 여부에 따른 설정 활성/비활성
		setSwitchEnabled("syncToiCloud", value: DataManager.iCloudAvailable)
		runBuyEXPackModal = false
	}
	
	func setSwitchData(_ settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).isOn = true
				print("Saved data is on:", settingsArray[i].settingsID)
				break;
			}
		} //end for
	} //end func
	func setSwitchEnabled(_ settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).isEnabled = value
				break
			}
		} //end for
	} //end func
	
    /// table setup
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell:CustomTableCell = tableView.cellForRow(at: indexPath) as! CustomTableCell
		//element touch handler
		
		switch (cell.cellID) {
			case "buyUP":
				runBuyEXPackModal = true
				viewCloseAction( )
				break
			case "restorePurchases":
				let restoreConfirmAlert:UIAlertController =
					UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("storeRestoreConfirm"), preferredStyle: UIAlertControllerStyle.alert)
				restoreConfirmAlert.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
					//Restore
					PurchaseManager.restorePurchases(callback: self.restoreFinishedCallback)
				}))
				restoreConfirmAlert.addAction(UIAlertAction(title: LanguagesManager.$("generalCancel"), style: .cancel, handler: { (action: UIAlertAction!) in
					//Cancel
				}))
				present(restoreConfirmAlert, animated: true, completion: nil)
				
				break
			case "ratingApplication":
				UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/app/id1128109120")!)
				break
			case "startGuide":
				GlobalSubView.startingGuideView.modalPresentationStyle = .overFullScreen
				self.present(GlobalSubView.startingGuideView, animated: true, completion: nil)
				break
			case "donateUP":
				/// 후원
				cell.titleLabelPointer?.text = LanguagesManager.$("settingsDonateThanks")
				
				UnityAdsManager.showUnityAD(self, placementID: UnityAdsManager.PlacementAds.donateManuallyAD.rawValue, callbackFunction: donateAdsFinishedHandler, showFailCallbackFunction: internetConnectionErrorHandler)
				
				break
			case "gotoUPProject":
				UIApplication.shared.openURL(URL(string: "https://up.avngraphic.kr/?l=" + LanguagesManager.currentLocaleCode)!)
				break
			case "languageChange":
				navigationCtrl.pushViewController(self.languagesView, animated: true)
				break
			case "indieGames":
				navigationCtrl.pushViewController(self.indieGamesView, animated: true)
				break
			case "credits":
				navigationCtrl.pushViewController(self.creditsView, animated: true)
				creditsView.creditsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
				break
			////// EXPERIMENTS
			case "experiments-notallowed-alarms":
				navigationCtrl.pushViewController(self.experimentAlarmSettingsView, animated: true)
				break
			case "debug-test-info":
				navigationCtrl.pushViewController(self.experimentTestingInfoView, animated: true)
				break
			////////
			/// Testers menu
			case "notice-fortesters":
				navigationCtrl.pushViewController(self.testersWebView, animated: true)
				break
			//////////////////////
			default: break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	} //end func
	
	/////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return tablesArray.count //최대 섹션보다 적게하면 그 섹션이 안보임.
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
            case 0:
                return LanguagesManager.$("generalSettings")
			case 1:
				return LanguagesManager.$("generalBuySettings")
            case 2:
                return LanguagesManager.$("generalGuide")
			case 3: //DEV, TEST
				return LanguagesManager.$("settingsExperiments")
            default:
                return "-"
        } //end switch [section labels]
    } //end func
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch(section) {
			//case 3: //DEV, TEST
			//	return "주의: 실험실에 있는 내용은 소리없이 추가되거나 삭제될 수 있습니다.";
			default:
				return ""
		} //end switch
	}
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tablesArray[section] ).count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] )[(indexPath as NSIndexPath).row] as! UITableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    ////////////////
	func donateAdsFinishedHandler() {
		DeviceManager.alert(title: LanguagesManager.$("settingsDonateThanks"), subject: LanguagesManager.$("donateThanksMessage"), promptTitle: LanguagesManager.$("generalOK"), callback: nil)
	} // end if
	func internetConnectionErrorHandler() {
		self.alert(title: LanguagesManager.$("generalError"), subject: LanguagesManager.$("generalCheckInternetConnection"), promptTitle: LanguagesManager.$("generalOK"), callback: nil)
	} // end if
	
	override func viewCloseAction() {
		//Save changes
		saveChasngesToSystem()
		
		super.viewCloseAction()
    } //end func
	////////////////
	override func viewDisappearedCompleteHandler() {
		if (runBuyEXPackModal == true) {
			//Buy Modal 열기
			
			ViewController.selfView!.showUPBuyView( nil )
			runBuyEXPackModal = false
		} //end if
	} //end func
	
	
	func saveChasngesToSystem() {
		for i:Int in 0 ..< settingsArray.count {
			switch(settingsArray[i].settingsID) {
				case "showIconBadge":
					DataManager.setDataBool((settingsArray[i].settingsElement as! UISwitch).isOn, key: DataManager.settingsKeys.showBadge)
					break
				case "syncToiCloud":
					DataManager.setDataBool((settingsArray[i].settingsElement as! UISwitch).isOn, key: DataManager.settingsKeys.syncToiCloud)
					if ((settingsArray[i].settingsElement as! UISwitch).isOn == true) {
						print("Settings-Changed iCloud vals")
						DataManager.loadiCloudDefaults()
					} //end if
					break
				default: //잉어킹: 잉어.. 잉어!! 그러나 아무 일도 일어나지 않았다
					break
			} //end switch [settingsID]
		} //end for [i]
		DataManager.save()
	} //end func
	
	func switchChangedEvent( _ target:UISwitch ) {
		print("switch changed. saving.")
		saveChasngesToSystem()
	} //end func
	
    //Tableview cell view create
    func createSettingsToggle(_ name:String, defaultState:Bool, settingsID:String ) -> CustomTableCell {
        let tCell:CustomTableCell = CustomTableCell()
        let tLabel:UILabel = UILabel()
		let tSwitch:UISwitch = UISwitch()
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3)
		switch(settingsID) { //특정 조건으로 아이콘 구분
			case "showIconBadge": tIconFileStr = "comp-icons-settings-badge"; break
			case "syncToiCloud": tIconFileStr = "comp-icons-settings-icloud"; break
			default:
				if (settingsID.range(of: "experiments-") != nil) {
					//실험실 아이콘?
					tIconFileStr = "comp-icons-settings-experiments"
				} else {
					tIconFileStr = "comp-icons-blank"
				} //end if
			break
		} //end switch
		
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8
		tIconImg.image = UIImage( named: tIconFileStr + ".png" )
		tCell.addSubview(tIconImg)
		
        let settingsObj:SettingsElement = SettingsElement()
        settingsObj.settingsID = settingsID
		tCell.cellID = settingsID
        settingsObj.settingsElement = tSwitch //Anyobject
        
        //해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
        tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: self.modalView.view.frame.width * 0.6, height: 45)
        tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 45)
        tCell.backgroundColor = UIColor.white
		
        tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - 8
        tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2
		
        tCell.addSubview(tLabel)
		tCell.addSubview(tSwitch)
		
		tSwitch.addTarget(self, action: #selector(SettingsView.switchChangedEvent(_:)), for: .valueChanged)
		
        tLabel.text = name
		tLabel.font = UIFont.systemFont(ofSize: 16)
		
        //push to settingselement
        settingsArray += [settingsObj]
        
        return tCell
    } //end func
	
    func createSettingsOnlyLabel(_ name:String, menuID:String ) -> CustomTableCell {
        let tCell:CustomTableCell = CustomTableCell()
        let tLabel:UILabel = UILabel()
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView()
		var tIconFileStr:String = ""
		var tIconWPadding:CGFloat = 0
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3)
		switch(menuID) { //특정 조건으로 아이콘 구분
			case "startGuide": tIconFileStr = "comp-icons-settings-guide"; break;
			case "ratingApplication": tIconFileStr = "comp-icons-settings-rating"; break;
			case "indieGames": tIconFileStr = "comp-icons-settings-newgames"; break;
			case "credits": tIconFileStr = "comp-icons-settings-developers"; break;
			
			case "donateUP": tIconFileStr = "comp-icons-settings-donate"; break;
			case "gotoUPProject": tIconFileStr = "comp-icons-settings-projectup"; break;
			case "languageChange": tIconFileStr = "comp-icons-settings-language"; break;
			
			case "buyUP": tIconFileStr = "comp-icons-shop-buy"; break;
			case "restorePurchases": tIconFileStr = "comp-icons-shop-restore"; break;
			case "useCoupon": tIconFileStr = "comp-icons-shop-code"; break;
			case "notice-fortesters": tIconFileStr = "comp-icons-settings-special-testers"; break;
			default:
				if (menuID.range(of: "experiments-") != nil) {
					//실험실 아이콘?
					
					switch(menuID) {
						//case "experiments-notallowed-alarms": tIconFileStr = "comp-icons-settings-experiments"; break;
						default: tIconFileStr = "comp-icons-settings-experiments"; break;
					}
				} else {
					tIconFileStr = "comp-icons-blank"
				}
				break
		} //end switch [menuID]
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8
		tIconImg.image = UIImage( named: tIconFileStr + ".png" )
		tCell.addSubview(tIconImg)
		
        let settingsObj:SettingsElement = SettingsElement()
        settingsObj.settingsID = menuID
		tCell.cellID = menuID
		
        settingsObj.settingsElement = nil //Anyobject
        
        //해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
        tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: self.modalView.view.frame.width, height: 45)
        tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 45)
        tCell.backgroundColor = UIColor.white
        
        tCell.addSubview(tLabel)
		tLabel.text = name
		
        tCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        tLabel.font = UIFont.systemFont(ofSize: 16)
		
		tCell.titleLabelPointer = tLabel
		
        settingsArray += [settingsObj]
        return tCell
    } //end func
	////////////////
	
	func showProductNotAvailable() {
		let alertWindow:UIAlertController = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("storeBuyNotAvailable"), preferredStyle: UIAlertControllerStyle.alert);
		alertWindow.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
		}));
		present(alertWindow, animated: true, completion: nil);
	} //end function
	func showRestoreFailed() {
		let alertWindow:UIAlertController = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("storeRestoreFailed"), preferredStyle: UIAlertControllerStyle.alert);
		alertWindow.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
		}));
		present(alertWindow, animated: true, completion: nil);
	}
	func showRestoreSucceed() {
		let alertWindow:UIAlertController = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("storeRestoreSuccess"), preferredStyle: UIAlertControllerStyle.alert);
		alertWindow.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
		}));
		present(alertWindow, animated: true, completion: nil);
	}
	
	//// shop callbacks
	func restoreFinishedCallback(_ isSucced:Bool ) {
		if (isSucced) { //restore OK
			showRestoreSucceed()
		} else {
			showRestoreFailed()
		}
	} //end func
	
}
