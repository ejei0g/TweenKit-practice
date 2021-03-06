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
// MARK: - Constants
fileprivate let defaultBackgroundColorTop = UIColor(red: 0.263, green: 0.118, blue: 0.565, alpha: 1.00)
fileprivate let defaultBackgroundColorBottom = UIColor(red: 1.000, green: 0.357, blue: 0.525, alpha: 1.00)

//MARK: - ViewController

class ViewController: UIViewController {
    let scheduler = ActionScheduler() //2.
    let scheduler2 = ActionScheduler()
    
    @IBOutlet weak var testButton: UIButton!
    
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
        view.layer.addSublayer(gradientLayer)
        view.addSubview(myFirstSquareView)
        view.addSubview(mySecondSquareView)
        view.addSubview(rocketImageView)
        view.addSubview(slider)
        //myFirstAnimation()
        //moveAndColorAnimation()
        
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
        
        //myArcActions()
        //myBezierActions()
        
        let backgroundActions = changedBackgroundColor()
        actionScrubber = ActionScrubber(action: backgroundActions)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
       
        // Layout Slider
        slider.sizeToFit()
        let margin = CGFloat(5)
        slider.frame = CGRect(x: margin,
                              y: view.bounds.size.height - slider.bounds.size.height - 50,
                              width: view.bounds.size.width - (margin * 2),
                              height: slider.bounds.size.height);
    }
    //MARK: - Arc Actions
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
    
    //MARK: - Bezier Actions
    
    //add rocket image. (asset 추가, subView추가)
    private let rocketImageView: UIImageView = {
        let image = UIImage(named: "Rocket")!
        let imageView = UIImageView(image: image)
        let scale = CGFloat(0.2)
        imageView.frame.size = CGSize(width: image.size.width * scale,
                                      height: image.size.height * scale)
        return imageView
    }()
    
    //path 설정.
    private var path: UIBezierPath {
        let bounds = view.bounds
        
        let controlPointsYOffset = bounds.width * 0.4
        let endPointsYOffset = bounds.size.width * 0.2
        
        let start = CGPoint(x: 0,
                            y: bounds.size.height/2 + endPointsYOffset)
        let control1 = CGPoint(x: bounds.size.width/3,
                               y: bounds.size.height/2 + controlPointsYOffset)
        let control2 = CGPoint(x: bounds.size.width/3*2,
                               y: bounds.size.height/2 - controlPointsYOffset)
        let end = CGPoint(x: bounds.size.width,
                          y: bounds.size.height/2 - endPointsYOffset - bounds.size.width*0.1)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: control1, controlPoint2: control2)
        return path
    }
    
    func myBezierActions() {

        let action = BezierAction(path: path.asBezierPath(), duration: 4.0) {
            [unowned self] (postion, rotation) in

            self.rocketImageView.center = postion

            let rocketRotation = CGFloat(rotation.value)
            self.rocketImageView.transform = CGAffineTransform(rotationAngle: rocketRotation)
        }

        action.easing = .exponentialInOut
        let repeatedAction = action.repeatedForever()
   
        //scheduler.run(action: repeatedAction)
        
        //Scrubbable
        actionScrubber = ActionScrubber(action: action)

    }
    
    //MARK: - Scrubbable Actions
    //1. add slider and scrubbable and sliderValueChanged func
    private var actionScrubber: ActionScrubber?
    
    private let slider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isUserInteractionEnabled = true
        slider.isContinuous = true
        return slider
    }()
    
    @objc private func sliderValueChanged() {
        actionScrubber?.update(t: Double(slider.value))
    }
    //2. action setting sequence
    
    @IBAction func pushTestButton(_ sender: UIButton) {
        self.slider.value += 0.1
        sliderValueChanged()
    }
    
    //MARK: - Background
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()
    //  gradientLayer.frame = view.bounds  <- in viewdidlayout
    
    private var backgroundColorTop = defaultBackgroundColorTop {
        didSet{ updateBackgroundGradient() }
    }
    
    private var backgroundColorBottom = defaultBackgroundColorBottom {
        didSet{ updateBackgroundGradient() }
    }
    
    private func updateBackgroundGradient() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = [backgroundColorTop.cgColor, backgroundColorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [0.0, 1.0]
        
        CATransaction.commit()
    }
    
    func changedBackgroundColor() -> FiniteTimeAction {
        let duration = 2.0
        // Change background color
        let changeBackgroundColorTop = InterpolationAction(from: defaultBackgroundColorTop,
                                                           to: UIColor(red: 0.118, green: 0.376, blue: 0.682, alpha: 1.00),
                                                           duration: duration,
                                                           easing: .exponentialOut,
                                                           update: { [unowned self] in self.backgroundColorTop = $0 })
        
        let changeBackgroundColorBottom = InterpolationAction(from: defaultBackgroundColorBottom,
                                                              to: UIColor(red: 0.569, green: 0.824, blue: 0.941, alpha: 1.00),
                                                              duration: duration,
                                                              easing: .exponentialOut,
                                                              update: { [unowned self] in self.backgroundColorBottom = $0 })
        // Create group
        let group = ActionGroup(actions: changeBackgroundColorTop, changeBackgroundColorBottom)
        
        return group
    }
    
    
    //end ViewController
}

//MARK: - Ex: CALayer.center

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
