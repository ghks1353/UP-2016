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
	func encodeWithCoder(aCoder: NSCoder!) {
		aCoder.encodeInteger(characterLevel, forKey: "characterLevel");
		aCoder.encodeInteger(characterExp, forKey: "characterExp");
		
		aCoder.encodeObject(characterLevelChecksum, forKey: "characterLevelChecksum");
		aCoder.encodeObject(characterExpChecksum, forKey: "characterExpChecksum");
		
	}
	
	//Decode from NSData to class
	init(coder aDecoder: NSCoder!) {
		characterLevel = aDecoder.decodeIntegerForKey("characterLevel");
		characterExp = aDecoder.decodeIntegerForKey("characterExp");
		
		characterLevelChecksum = aDecoder.decodeObjectForKey("characterLevelChecksum") as! String;
		characterExpChecksum = aDecoder.decodeObjectForKey("characterExpChecksum") as! String;
	}
	
	override init() {
	}
	
	internal func initObject( lv:Int = 0, Exp:Int = 0 ) {
		characterLevel = lv; characterExp = Exp;
	}
	
}