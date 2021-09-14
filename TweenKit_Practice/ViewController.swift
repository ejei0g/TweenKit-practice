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
    let scheduler2 = ActionScheduler()
    
    // The view we will be animating
    private let myFirstSquareView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.red
        view.center = CGPoint(x: 100, y: 100)
        view.frame.size = CGSize(width: 70, height: 70)
        return view
    }()
    
    private let mySecondSquareView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.red
        view.center = CGPoint(x: 100, y: 700)
        view.frame.size = CGSize(width: 70, height: 70)
        return view
    }()
    
    func myFirstAnimation() {
        let fromRect = CGRect(x: 50, y: 50, width: 40, height: 40)
        let toRect = CGRect(x: 100, y: 500, width: 300, height: 100)
        // 기본 단위인 액션을 만들자.
        let action = InterpolationAction(from: fromRect,
                                         to: toRect,
                                         duration: 1.0,
                                         easing: .exponentialInOut) {
            [unowned self] in self.myFirstSquareView.frame = $0
        }
        // 액션을 반복시킬수 있다. repeat함수를 사용해보자
        //let repeatedAction = action.yoyo().repeatedForever()
        let repeatedAction = action.repeatedForever()
        // 액션을 실행.
        scheduler.run(action: repeatedAction)
        
    }
    
    func moveAndColorAnimation() {
        
        // Create a move action
        let AGfromRect = CGRect(x: 50, y: 50, width: 40, height: 40)
        let AGtoRect = CGRect(x: 100, y: 100, width: 200, height: 100)
        
        let move = InterpolationAction(from: AGfromRect,
                                       to: AGtoRect,
                                       duration: 2.0,
                                       easing: .exponentialOut) {
            [unowned self] in self.mySecondSquareView.frame = $0
        }
        
        // Create a color change action
        let changeColor = InterpolationAction(from: UIColor.red,
                                              to: UIColor.orange,
                                              duration: 2.0,
                                              easing: .exponentialOut) {
            [unowned self] in self.mySecondSquareView.backgroundColor = $0
        }
        
        // Make a group to run them at the same time
        let moveAndChangeColor = ActionGroup(actions: move, changeColor)
        //scheduler2.run(action: moveAndChangeColor)
        let repeat2 = moveAndChangeColor.yoyo().repeatedForever()
        scheduler.run(action: repeat2)
        
    }
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(myFirstSquareView)
        view.addSubview(mySecondSquareView)
        
        myFirstAnimation()
        moveAndColorAnimation()
        
        //스케쥴러는 어떤거를 사용해도 상관이 없음
        //대신 각각의 애니메이션이 사용하는 뷰는 하나의 애니메이션당 하나의 뷰가 필요함.
        //예를 들어 첫번째 애니메이션과 두번째 애니메이션이 같은 뷰를 사용한다면, 나중에 실행된 애니메이션의 액션이 뷰를 통해 실행됨.
        
        //Arc Actions
        
        // Create the circle layers
        let numCircles = 4
        
        for i in 0..<numCircles {
            
            let layer = CALayer()
            
            let alpha = CGFloat(i+1) / CGFloat(numCircles)
            layer.backgroundColor = UIColor.red.withAlphaComponent(alpha).cgColor
            layer.frame.size = CGSize(width: 10, height: 10)
            layer.cornerRadius = layer.bounds.size.width/2
            view.layer.addSublayer(layer)
            self.circleLayers.append(layer)
        }
        circleLayers = circleLayers.reversed()
        
        myArcActions()
    }
    
    //Arc Actions
    
    private var circleLayers = [CALayer]() //서클 레이어들 변수 설정.
    
    func myArcActions() {
        
        let radius = 50.0
        
        // Create an ArcAction for each circle layer
        let actions = circleLayers.map{
            layer -> ArcAction<CGPoint> in
            
            let action = ArcAction(center: self.view.center,
                                   radius: radius,
                                   startDegrees: 0,
                                   endDegrees: 360,
                                   duration: 1.3) {
                //Error: extension키워드를 통해서 CALayer에 center 함수 정의.
                [unowned layer] in layer.center = $0
            }
            action.easing = .sineInOut
            return action
            
        }
        
        // Run the actions in a staggered group
        let group = ActionGroup(staggered: actions, offset: 0.125)
        
        // Repeat forever
        let repeatForever = group.repeatedForever()
        
        // Run the action
        scheduler.run(action: repeatForever)
        
    }
}

extension CALayer {
    var center: CGPoint {
        get{
            return CGPoint(x: frame.origin.x + frame.size.width/2, y: frame.origin.y + frame.size.height/2)
        }
        set{
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            frame.origin = CGPoint(x: newValue.x - frame.size.width/2, y: newValue.y - frame.size.height/2)
            CATransaction.commit()
        }
    }
}
