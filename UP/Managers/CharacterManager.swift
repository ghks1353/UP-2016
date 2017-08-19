//
//  CharacterManager.swift
//  UP
//
//  Created by ExFl on 2016. 5. 23..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
//import CryptoSwift;

class CharacterManager {
	
	//캐릭터 레벨, 경험치 등에 대한 관리. 체크섬 관리가 되기 때문에 여기서 조작해야함
	
	static var currentCharInfo:CharacterInfo = CharacterInfo();
	
	static func getExpProgress() -> Float {
		let maxEXPLevelIn:Float = 6 + (4 * Float(currentCharInfo.characterLevel));
		
		return Float(currentCharInfo.characterExp) / maxEXPLevelIn;
	}
	
	static func giveEXP(_ amount:Int = 0) {
		//exp 채움. 
		
		//해당 레벨의 최대 경험치 추산:
		
		//1레벨일 경우 10, 2=14, 3=18 ...
		let maxEXPLevelIn:Int = 6 + (4 * currentCharInfo.characterLevel);
		currentCharInfo.characterExp += amount;
		if (currentCharInfo.characterExp >= maxEXPLevelIn) {
			//Level UP
			currentCharInfo.characterExp = 0;
			currentCharInfo.characterLevel += 1;
		} //레벨업 루틴 끝
		
		//체크섬을 대입.
		//currentCharInfo.characterLevelChecksum = makeLvChecksum(currentCharInfo.characterLevel);
		//currentCharInfo.characterExpChecksum = makeExpChecksum(currentCharInfo.characterExp);
		
		print("current exp:", currentCharInfo.characterExp, ", max:", maxEXPLevelIn, ", percent:", getExpProgress());
		
		save(); //저장
	}
	
	//현 캐릭터info 객체를 다른 쪽으로 카피. (정확히는 데이터만 덮어쓰기)
	static func setDataTo( _ infoObject:CharacterInfo ) {
		currentCharInfo.characterLevel = infoObject.characterLevel;
		currentCharInfo.characterExp = infoObject.characterExp;
		
		//currentCharInfo.characterLevelChecksum = makeLvChecksum(infoObject.characterLevel);
		//ßcurrentCharInfo.characterExpChecksum = makeExpChecksum(infoObject.characterExp);
		save();
	}
	
	static func merge() {
		//로드와 동시에 체크섬 검사하여 이상하면 레벨 1, exp 0으로 롤백. (처음 init과정이기도.)
		
		if (DataManager.nsDefaults.object( forKey: DataManager.characterInfoKeys.info ) != nil) {
			let tmpInfo:Data = DataManager.nsDefaults.object( forKey: DataManager.characterInfoKeys.info ) as! Data;
			currentCharInfo = NSKeyedUnarchiver.unarchiveObject(with: tmpInfo) as! CharacterInfo;
		} else {
			//아래 과정에서 다 알아서 해줌
		}
		//let lvChecksum:String = makeLvChecksum(currentCharInfo.characterLevel);
		//let expChecksum:String = makeExpChecksum(currentCharInfo.characterExp);
		/*if (currentCharInfo.characterLevelChecksum != lvChecksum) {
			currentCharInfo.characterLevel = 1; //레벨 1로 초기화
			//currentCharInfo.characterLevelChecksum = makeLvChecksum(1);
		}
		if (currentCharInfo.characterExpChecksum != expChecksum) {
			currentCharInfo.characterExp = 0; //경험치 0으로 초기화
			//currentCharInfo.characterExpChecksum = makeExpChecksum(0);
		}
		*/
		save() //저장
	}
	/*
	static func makeLvChecksum(_ level:Int) -> String {
		return UPUtils.SHA256( String(level) + "lvsalt" + String(level * 2) );
	}
	static func makeExpChecksum(_ exp:Int) -> String {
		return UPUtils.SHA256( String(exp) + "exsalt" + String(exp * 4) );
	}
	*/
	static func save() {
		//DataManager를 통해 저장
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: currentCharInfo), forKey: DataManager.characterInfoKeys.info);
		DataManager.save();
	}
	
	
}
