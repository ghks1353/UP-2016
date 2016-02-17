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
		GameInfoObj(gameName: "불멸의 용가리", gameGenre: "점프액션", gameDifficultyLevel: 3, gameDescription: "이 게임은 아침마다 당신에게 깊은 감동을 선사 해 줄 것입니다.", gameColor: UPUtils.colorWithHexString("6283C6"), textColor: UIColor.whiteColor())
	];
	
	//GameID => Index
	static func getGameIDWithObject(gameObj:GameInfoObj) -> Int {
		for (var i:Int = 0; i < list.count; ++i) {
			if(list[i].gameLangName == gameObj.gameLangName && list[i].gameLangGenre == gameObj.gameLangGenre && list[i].gameDifficulty == gameObj.gameDifficulty) {
				return i;
			}
		}
		return -1; //not found
	}
	
	
}