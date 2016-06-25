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
	
}