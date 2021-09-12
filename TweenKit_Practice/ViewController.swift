//
//  ViewController.swift
//  TweenKit_Practice
//
//  Created by Jaeyoung Lee on 2021/09/10.
//

// 1. 라이브러리 임포트,
// 2. 애니메이션을 실행시키기 위한 액션스케줄러 인스턴스화.
// 3. 트윈킷은 액션 단위로 이루어져 있음. 복잡한 애니메이션을 만들기 위해 연결, 그룹화할 수 있는 작은 애니메이션 단위
// 4. 하나의 작업을 만든 후, 스케쥴러에게 실행하도록 명령

import UIKit
import TweenKit //1.

class ViewController: UIViewController {
    let scheduler = ActionScheduler() //2.
    
    // The view we will be animating
    private let squareView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.red
        view.center = CGPoint(x: 100, y: 100)
        view.frame.size = CGSize(width: 70, height: 70)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 5. 애니메이션 작업 만들기
        // Tweenable protocol을 채택하는친구들은 사용가능

        // view 추가!!
        view.addSubview(squareView)
        
        // 이동할 도형 설정
        let fromRect = CGRect(x: 50, y: 50, width: 40, height: 40)
        let toRect = CGRect(x: 100, y: 100, width: 200, height: 100)
                
        // 기본 단위인 액션을 만들자.
        let action = InterpolationAction(from: fromRect,
                                         to: toRect,
                                         duration: 1.0,
                                         easing: .exponentialInOut) {
            [unowned self] in self.squareView.frame = $0
        }
        
        // 액션을 반복시킬수 있다. repeat함수를 사용해보자
        //let repeatedAction = action.yoyo().repeatedForever()
            
        // 액션을 실행.
        scheduler.run(action: action)

    }

}

