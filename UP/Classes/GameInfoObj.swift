//
//  GameInfoObj.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit;

class GameInfoObj {
	
	//gameID = 게임 배열에 저장된 인덱스
	init(gameIDf:String, gameName:String, gameGenre:String, gameDifficultyLevel:Int, gameDescription:String, gameFileName:String, gameColor:UIColor, textColor:UIColor) {
		//Get variables from lang file
		gameID = gameIDf;
		gameLangName = LanguagesManager.$(gameName); gameLangGenre = LanguagesManager.$(gameGenre);
		gameDifficulty = gameDifficultyLevel;
		gameLangDescription = LanguagesManager.$(gameDescription);
		
		gameThumbFileName = gameFileName;
		gameBackgroundUIColor = gameColor;
		gameTextUIColor = textColor;
	}
	
	internal var gameID:String = "";
	internal var gameLangName:String = "";
	internal var gameLangGenre:String = "";
	internal var gameDifficulty:Int = 0; //Level 0~5
	internal var gameLangDescription:String = "";
	internal var gameThumbFileName:String = "";
	internal var gameBackgroundUIColor:UIColor = UIColor.white;
	internal var gameTextUIColor:UIColor = UIColor.black;
	
}
