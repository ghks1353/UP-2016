//
//  CharacterInfo.swift
//  UP
//
//  Created by EXFl on 2016. 5. 23..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

//Object 째로 key-storage에 저장할것이기 때문에 nsClass로 만듬
class CharacterInfo:NSObject {
	
	//레벨, 경험치
	internal var characterLevel:Int = 0;
	internal var characterExp:Int = 0; //int형태로 저장.
	
	//주작 방지를 위한 체크섬 저장
	internal var characterLevelChecksum:String = "";
	internal var characterExpChecksum:String = "";
	
	//Class to NSData
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(characterLevel, forKey: "characterLevel");
		aCoder.encode(characterExp, forKey: "characterExp");
		
		aCoder.encode(characterLevelChecksum, forKey: "characterLevelChecksum");
		aCoder.encode(characterExpChecksum, forKey: "characterExpChecksum");
		
	}
	
	//Decode from NSData to class
	init(coder aDecoder: NSCoder!) {
		characterLevel = aDecoder.decodeInteger(forKey: "characterLevel");
		characterExp = aDecoder.decodeInteger(forKey: "characterExp");
		
		characterLevelChecksum = aDecoder.decodeObject(forKey: "characterLevelChecksum") as! String;
		characterExpChecksum = aDecoder.decodeObject(forKey: "characterExpChecksum") as! String;
	}
	
	override init() {
	}
	
	internal func initObject( _ lv:Int = 0, Exp:Int = 0 ) {
		characterLevel = lv; characterExp = Exp;
	}
	
}
