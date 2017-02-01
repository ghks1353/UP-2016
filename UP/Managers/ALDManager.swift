//
//  ALDManager.swift
//  UP
//
//  Created by ExFl on 2017. 1. 29..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import SQLite

class ALDManager {
	//자동 레벨 디자인 관리 클래스
	
	static var generatedLevelMultiply:Float = 1
	static var generatedTimeMultiply:Float = 30
	
	static func buildLevel() {
		//최대 7개 기록으로 만듬
		let targetTable:Table? = DataManager.gameResultTable()
		var resultDatasArray:Array<[String:Int]> = []
		
		//맞은회수 평균치 계수
		var hitMultipl:Float = 0
		//플레이시간 평균치 계수
		var timeMultipl:Float = 0
		//클리어 평균치 계수
		var clearMultipl:Float = 0
		
		do {
			for dbResult in try DataManager.db()!.prepare(
				targetTable!
					.order( Expression<Int64>("id").desc )
					.limit( 7, offset: 0 )
				) {
				var tmpDic:[String:Int] = [:]
					tmpDic["gameCleared"] = Int( dbResult[Expression<Int64>("gameCleared")] )
					tmpDic["playTime"] = Int( dbResult[Expression<Int64>("playTime")] )
					tmpDic["resultMissCount"] = Int( dbResult[Expression<Int64>("resultMissCount")] )
				resultDatasArray += [tmpDic]
					
				hitMultipl += Float( dbResult[Expression<Int64>("resultMissCount")] )
				timeMultipl += Float( dbResult[Expression<Int64>("playTime")] )
				clearMultipl += Float( dbResult[Expression<Int64>("gameCleared")] )
			} //end for
		} catch {
			
		} //end result
		
		if (resultDatasArray.count == 0) {
			generatedLevelMultiply = 1
			generatedTimeMultiply = 30
			print("ALD build failed: no data. resetting to default value")
			return
		}
		
		//length만큼 나눠 계수계산
		hitMultipl = hitMultipl / Float( resultDatasArray.count )
		timeMultipl = timeMultipl / Float( resultDatasArray.count )
		clearMultipl = clearMultipl / Float( resultDatasArray.count )
		
		//계수측정값대로 계산 (메모해논게 있음)
		generatedLevelMultiply = 24 / min(max(8, hitMultipl), 96)
		generatedLevelMultiply = generatedLevelMultiply * max(0.5, 1 - ((120/max(timeMultipl,120)) / 6))
		generatedLevelMultiply = generatedLevelMultiply * (clearMultipl < 0.5 ? 0.5 : 1)
		
		generatedTimeMultiply = max(30, 30 * (generatedLevelMultiply / 1.25))
		
		print("ALD build finished: m",generatedLevelMultiply," t",generatedTimeMultiply)
	} //end func
	
}
