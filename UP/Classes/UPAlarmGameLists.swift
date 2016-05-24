//
//  UPAlarmGameLists.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class UPAlarmGameLists {
	
	static var list:Array<GameInfoObj> = [
		GameInfoObj(
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
	
	
}