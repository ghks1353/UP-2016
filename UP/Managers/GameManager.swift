//
//  GameManager.swift
//  UP
//
//  Created by ExFl on 2016. 5. 29..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class GameManager {
	
	static var list:Array<GameInfoObj> = [
		GameInfoObj(
			gameIDf: "jumpup", /* <- 게임 ID 식별자 */
			gameName: "gameNameJumpUP", gameGenre: "gameGenreJumpAction", gameDifficultyLevel: 3,
			gameDescription: "gameDescriptionJumpUP", gameFileName: "game-thumb-jumpup",
			gameColor: UPUtils.colorWithHexString("FF9933"), textColor: UIColor.whiteColor())
	];
	
	//GameID => Index
	static func getGameIDWithObject(gameObj:GameInfoObj) -> Int {
		for i:Int in 0 ..< list.count {
			if(list[i].gameLangName == gameObj.gameLangName && list[i].gameLangGenre == gameObj.gameLangGenre && list[i].gameDifficulty == gameObj.gameDifficulty) {
				return i;
			}
		}
		return -1; //not found
	}
	
	//GameID => Thumbnail
	static func getThumbnailWithGameID(gameID:Int) -> String {
		switch(gameID) { //gameid thumbnail show
			case 0:
				return "game-thumb-jumpup.png";
			default: break;
		}
		return "game-thumb-sample.png";
	}
	
	//GameID => LeaderboardID
	static func getLeadboardIDWithGameID(gameID:Int) -> String {
		switch(gameID) {
			case 0:
				return "leaderboard_jumpup";
			default: break;
		}
		return "";
	}
	
	
	////// Save game's bestscore to store, and save // ** GAME MODE, NOT ALARM **
	static func saveBestScore( gameID:Int, score:Int ) {
		let gameStoreKey:String = getStoreKeyWithGameID( gameID );
		
		let gameScore:Int = DataManager.nsDefaults.integerForKey(gameStoreKey);
		if (gameScore < score) {
			//기존 기록이 현재 기록보다 적으면, 최고기록 달성으로 치고 데이터를 저장함.
			DataManager.nsDefaults.setValue(score, forKey: gameStoreKey);
		}
		// 저장. (겸사겸사 클라우드로도 연동됨)
		DataManager.save();
	}
	
	// 위와는 반대로, 베스트스코어를 불러오는 일만 함
	static func loadBestScore( gameID:Int ) -> Int {
		let gameStoreKey:String = getStoreKeyWithGameID( gameID );
		return DataManager.nsDefaults.integerForKey(gameStoreKey);
	}
	
	//GameID => DataManager NSDefaults Key
	static func getStoreKeyWithGameID( gameID:Int ) -> String {
		switch (gameID) {
			case 0: // JumpUP
				return DataManager.gamesBestKeys.jumpup_best;
			default: break;
		}
		return "";
	}
	
}