//
//  GameInfoObj.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class GameData {
	
	//gameID = 게임 배열에 저장된 인덱스
	init(gameIDf:String, gameName:String, gameGenre:String, gameDifficultyLevel:Int, gameDescription:String, gameFileName:String, gameColor:UIColor, textColor:UIColor) {
		//Get variables from lang file
		gameID = gameIDf
		gameLangName = LanguagesManager.$(gameName)
		gameLangGenre = LanguagesManager.$(gameGenre)
		gameDifficulty = gameDifficultyLevel
		gameLangDescription = LanguagesManager.$(gameDescription)
		
		gameThumbFileName = gameFileName
		gameBackgroundUIColor = gameColor
		gameTextUIColor = textColor
	}
	
	var gameID:String = ""
	var gameLangName:String = ""
	var gameLangGenre:String = ""
	var gameDifficulty:Int = 0 //Level 0~5
	var gameLangDescription:String = ""
	var gameThumbFileName:String = ""
	var gameBackgroundUIColor:UIColor = UIColor.white
	var gameTextUIColor:UIColor = UIColor.black
	
}
