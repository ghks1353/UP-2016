//
//  StartGuideView.swift
//  UP
//
//  Created by ExFl on 2016. 7. 1..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class StartGuideView:UIViewController, UIScrollViewDelegate {
	
	///////// 시작 가이드 뷰
	static var selfView:StartGuideView?;
	
	var startingGuideBackgroundGradient:CAGradientLayer = CAGradientLayer();
	var guidePages:Int = 14; //총 가이드 페이지 수.
	var latestPage:Int = 0;
	
	var guideScrollView:UIScrollView = UIScrollView();
	
	var guideUIViews:Array<UIView> = [];
	var guideImagesArray:Array<UIImageView> = [];
	
	var guideTitleUILabelsArray:Array<UILabel> = [];
	var guideDescriptionUILabelsArray:Array<UILabel> = [];
	
	var guideExitInformationLabel:UILabel = UILabel();
	
	var guideUIPageControl:UIPageControl = UIPageControl();
	var gameGuideViewLoaded:Bool = false;
	
	override func viewDidLoad() {
		// view init func
		gameGuideViewLoaded = true;
		self.view.backgroundColor = UIColor.white;
		StartGuideView.selfView = self;
		
		//gradient background
		startingGuideBackgroundGradient.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
		startingGuideBackgroundGradient.colors = [ UPUtils.colorWithHexString("CBFFDC").cgColor , UPUtils.colorWithHexString("FFC9C9").cgColor ];
		self.view.layer.insertSublayer(startingGuideBackgroundGradient, at: 0);
		////////////////
		
		guideScrollView.delegate = self;
		guideScrollView.isPagingEnabled = true;
		guideScrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
		guideScrollView.contentSize = CGSize( width: self.view.frame.width * CGFloat(guidePages), height: self.view.frame.height );
		guideScrollView.showsVerticalScrollIndicator = false;
		guideScrollView.showsHorizontalScrollIndicator = false;
		self.view.addSubview(guideScrollView);
		
		//가이드 이미지 추가
		for i:Int in 0 ..< guidePages {
			let tmpScreenUIView:UIView = UIView();
			let tmpImage:UIImageView = UIImageView();
			
			let tmpTitleUILabel:UILabel = UILabel();
			let tmpDesUILabel:UILabel = UILabel();
			
			let globalVersionFileName:String = "modal-guide-images-all-" + String(i) + "-general";
			let localizedVersionFileName:String = "modal-guide-images-" + Languages.currentLocaleCode + "-" + String(i) + "-general";
			let fallbackFileName:String = "modal-guide-images-en-" + String(i) + "-general";
			
			//파일 검사해서 all버전이 없으면 각 로케일 버전으로 찾음
			var tmpImageFile:UIImage? = UIImage( named: globalVersionFileName );
			
			if (tmpImageFile != nil) {
				tmpImage.image = tmpImageFile;
			} else {
				tmpImageFile = UIImage( named: localizedVersionFileName );
				if (tmpImageFile != nil) {
					tmpImage.image = tmpImageFile;
				} else {
					tmpImage.image = UIImage( named: fallbackFileName );
				}
			}
			
			//이미지는 정중앙이 아니라, 살짝 위로 올라가있음
			tmpImage.frame = CGRect(x: self.view.frame.width / 2 - (255.6 * DeviceManager.maxScrRatioC) / 2
				, y: (self.view.frame.height / 2 - (454.4 * DeviceManager.maxScrRatioC) / 2) - (47 * DeviceManager.scrRatioC)
				, width: 255.6 * DeviceManager.maxScrRatioC, height: 454.4 * DeviceManager.maxScrRatioC);
			tmpScreenUIView.addSubview(tmpImage);
			
			//가이드 화면 위치 조정
			tmpScreenUIView.frame = CGRect(x: self.view.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: self.view.frame.height);
			guideScrollView.addSubview(tmpScreenUIView);
			
			/// 텍스트 생성
			tmpTitleUILabel.frame = CGRect(x: tmpScreenUIView.frame.minX, y: tmpImage.frame.maxY + (48 * DeviceManager.maxScrRatioC), width: self.view.frame.width, height: 18);
			tmpDesUILabel.frame = CGRect(x: tmpScreenUIView.frame.minX, y: tmpTitleUILabel.frame.maxY + (12 * DeviceManager.maxScrRatioC), width: self.view.frame.width, height: 18);
			
			tmpTitleUILabel.textColor = UPUtils.colorWithHexString("#461515");
			tmpDesUILabel.textColor = tmpTitleUILabel.textColor;
			tmpTitleUILabel.textAlignment = .center; tmpTitleUILabel.font = i == 0 ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16);
			tmpDesUILabel.textAlignment = .center; tmpDesUILabel.font = UIFont.systemFont(ofSize: 16);
			
			tmpTitleUILabel.text = Languages.$("startGuide-" + String(i) + "-A");
			tmpDesUILabel.text = Languages.$("startGuide-" + String(i) + "-B");
			
			guideScrollView.addSubview(tmpTitleUILabel);
			guideScrollView.addSubview(tmpDesUILabel);
			
			guideUIViews += [tmpScreenUIView];
			guideImagesArray += [tmpImage];
			guideTitleUILabelsArray += [tmpTitleUILabel];
			guideDescriptionUILabelsArray += [tmpDesUILabel];
		} //end for
		
		//페이지컨트롤 추가
		guideUIPageControl.frame = CGRect(x: 0, y: self.view.frame.height - 48, width: self.view.frame.width, height: 48);
		self.view.addSubview(guideUIPageControl);
		
		guideUIPageControl.numberOfPages = guidePages;
		guideUIPageControl.currentPage = 0;
		
		//밀어서 종료 안내문
		guideExitInformationLabel.frame = CGRect(x: 0, y: self.view.frame.height - 16 - 18, width: self.view.frame.width, height: 16);
		guideExitInformationLabel.textColor = UPUtils.colorWithHexString("#461515");
		guideExitInformationLabel.textAlignment = .center;
		guideExitInformationLabel.font = UIFont.boldSystemFont(ofSize: 14);
		guideExitInformationLabel.text = Languages.$("startGuideExitWithSwipe");
		
		self.view.addSubview(guideExitInformationLabel);
		guideExitInformationLabel.alpha = 0; //페이지 마지막으로 갔을 때만 보이게
		
	}
	
	//왼쪽으로 한번 더 밀어 종료하는 기능
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		if ((scrollView.contentOffset.x / scrollView.frame.size.width) - CGFloat(guidePages-1) > 0.1) {
			//창 종료시 Startguide 봤다고 저장
			DataManager.nsDefaults.set(true, forKey: DataManager.settingsKeys.startGuideFlag);
			
			//이 창 종료
			self.dismiss(animated: true, completion: nil);
		}
	}
	
	//페이징 및 안내문 관련
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		scrollViewDidEndDecelerating(scrollView);
	}
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber:Int = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width));
		latestPage = pageNumber;
		guideUIPageControl.currentPage = pageNumber;
		
		var goalAlpha:CGFloat = 0;
		if (pageNumber == guidePages - 1) {
			//마지막 페이지이면 안내를 추가
			goalAlpha = 1;
		} else {
			goalAlpha = 0;
		}
		
		if (guideExitInformationLabel.alpha != goalAlpha ) {
			UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
				self.guideExitInformationLabel.alpha = goalAlpha;
				self.guideUIPageControl.alpha = goalAlpha == 1 ? 0 : 1;
			}) { _ in
			}
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		UIApplication.shared.statusBarStyle = .default;
		
		//스크롤뷰 제자리로
		self.guideScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false);
		scrollViewDidEndDecelerating( guideScrollView );
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		//view disappear event handler
		UIApplication.shared.statusBarStyle = .lightContent;
	}
	
	func fitView(_ size: CGSize) {
		//Fit start-guide elements
		if (!gameGuideViewLoaded) {
			return;
		}
		//self.view.frame = CGRectMake(0, 0, size.width, size.height);
		startingGuideBackgroundGradient.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
		guideScrollView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
		guideScrollView.contentSize = CGSize( width: size.width * CGFloat(guidePages), height: size.height );
		
		//컴포넌트들 재정렬
		for i:Int in 0 ..< guidePages {
			guideUIViews[i].frame = CGRect(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height);
			var arrPoint:CGPoint = CGPoint();
			arrPoint.x = size.width / 2 - (255.6 * DeviceManager.maxScrRatioC) / 2;
			arrPoint.y = (size.height / 2 - (454.4 * DeviceManager.maxScrRatioC) / 2) - (47 * DeviceManager.scrRatioC);
			
			guideImagesArray[i].frame =
				CGRect(x: arrPoint.x
					, y: arrPoint.y
					, width: 255.6 * DeviceManager.maxScrRatioC, height: 454.4 * DeviceManager.maxScrRatioC);
			guideTitleUILabelsArray[i].frame = CGRect(x: guideUIViews[i].frame.minX, y: guideImagesArray[i].frame.maxY + (48 * DeviceManager.maxScrRatioC), width: size.width, height: 18);
			guideDescriptionUILabelsArray[i].frame = CGRect(x: guideUIViews[i].frame.minX, y: guideTitleUILabelsArray[i].frame.maxY + (12 * DeviceManager.maxScrRatioC), width: size.width, height: 18);
		}
		
		//재정렬되었으니 화면 오프셋도 같이.
		self.guideScrollView.setContentOffset(CGPoint(x: size.width * CGFloat(latestPage), y: 0), animated: false);
		
		guideUIPageControl.frame = CGRect(x: 0, y: size.height - 48, width: self.view.frame.width, height: 48);
		guideExitInformationLabel.frame = CGRect(x: 0, y: size.height - 16 - 18, width: size.width, height: 16);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
