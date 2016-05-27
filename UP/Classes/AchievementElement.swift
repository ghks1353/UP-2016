//
//  AchievementElement.swift
//  UP
//
//  Created by ExFl on 2016. 5. 27..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class AchievementElement {
	
	//클리어여부는 achievement merge시 확인해서 적용하고, 바뀐게 있으면 이벤트 알림.
	
	internal var id:String = ""; //도전과제 식별 ID
	
	//정보
	internal var name:String = ""; //도전과제명 (번역된 이름으로 매니저에서 init시 적용)
	internal var description:String = ""; //도전과제 설명
	
	//검사 변수 목록
	internal var checkTargets:Array<String> = Array<String>(); //검사하려는 변수가 목록에 들어갈 순 없으므로 string를 id처럼 사용, 포인터처럼 활용
	internal var equalStr:Array<String> = Array<String>(); //if문 조건연산자를 넣고 비슷하게 검사
	internal var checkVals:Array<Float> = Array<Float>(); //검사할 변수. bool타입의 경우는 0이면 false, 그게 아니면 1인거로..
	
	//리워드 목록
	internal var rewardsID:Array<String> = Array<String>(); //리워드 줄 ID. 이거도 내부 식별자처럼 사용...
	internal var rewardsAmount:Array<Float> = Array<Float>(); //리워드 줄만큼 양.
	
	//기타
	internal var isHiddenTitle:Bool = false; //타이틀의 가려짐 여부
	internal var isHiddenDescription:Bool = false; //설명의 가려짐 여부
	
	
	/// 프로그램 식별 내부 정보
	internal var isCleared:Bool = false; //Merge시 값이 바뀜
	
}