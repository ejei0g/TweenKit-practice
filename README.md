## TweenKit 라이브러리 사용법.
원본 깃을 참고하면 좋음, 리드미파일과 샘플 파일을 비교하면서 확인해보자.
[TweenKit](https://github.com/SteveBarnegren/TweenKit)

### Hello World
```swift
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
```
### Action Group
액션 그룹을 사용하면, 여러 액션들을 동시에 실행시킬 수 있다.
예를 들면, 도형도 움직이고 색깔도 변경시키고

InterpolationAction 함수를 통해서 다양한 액션을 구성.
- from -> to : 도형의 크기, 색
- duration : 속도? 번역은 지속이긴한데, 해당 시간동안 액션이 이뤄짐.
- easing: 움직임 : 갑자기 빨라졌다 느려졌다. 계속 일정한 속도 등등 다양한 옵션.
- 그리고 해당 액션이 실행될 뷰를 선택.

ActionGroup함수를 사용해서 모든 액션들의 그룹을 설정.
```swift
// Make a group to run them at the same time
let moveAndChangeColor = ActionGroup(actions: move, changeColor)
  ```
  scheduler.run으로 실행.
### repeat
  요요와 리핏의 차이는 요요는 왔다 갔다,
  리핏은 처음으로 돌아가서 다시 실행.

### yoyo
  yoyo함수 사용.
  액션이나, 액션그룹 데이터타입에 yoyo().repeat옵션 함수를 사용해서 반복시킬수 있음.
  ```swift
let repeat2 = moveAndChangeColor.yoyo().repeatedForever()

schedular2.run(action: repeat2)
  ```
  - 스케쥴러는 어떤거를 사용해도 상관이 없음
  - 대신 각각의 애니메이션이 사용하는 뷰는 하나의 애니메이션당 하나의 뷰가 필요함.
  - 예를 들어 첫번째 애니메이션과 두번째 애니메이션이 같은 뷰를 사용한다면, 나중에 실행된 애니메이션의 액션이 뷰를 통해 실행됨.


### Arc Action
  1. layer [] 선언
  ```swift
private var circleLayers = [CALayer]() //서클 레이어들 변수 설정.
  ```
  2. 원형을 표현하기 위해서 sub layer로 생성.
  - 알파값을 다르게 해주기 위해서 i/n으로 점점 진해지게 설정.
  - 백그라운드 + 알파
  - 레이어의 크기, 코너(원 ) 정하기
  - 해당 뷰의 레이어에 서브레이어로 추가.
  - 위에서 선언한 레이어배열에도 추가.
  ```swift
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
  ```
  3. ArcAction func 을 통해서 action에 대한 정의 (레이어에서 생성된 모든 서브레이어들에 대한 액션을 정의해줘야 한다.)
  ```swift
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
```
4. extension keywork를 통해서 center에 대한 정의를 추가.
```swift
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
```

### Bezier Actions

Bezier? [베지에 곡선](https://ko.wikipedia.org/wiki/%EB%B2%A0%EC%A7%80%EC%97%90_%EA%B3%A1%EC%84%A0)

> 한마디로 “베지에 곡선”이란 선분 위를 일정 속도로 움직이는 점과 그러한 점과 점을 잇는 또 다른 선분, 그리고 그 위를 일정 속도로 이동하는 또 다른 점 등을 조합해 최종적으로 특정 점이 그리는 궤적을 이용해 곡선을 그려내는 방법을 뜻한다. 이해하는 데 도움이 됐으리라 기대한다.

[중학생도 알 수 있는 베지에 곡선(Bezier Curves)](https://blog.coderifleman.com/2016/12/30/bezier-curves/)

```swift
let action = BezierAction(path: bezierPath, duration: 4.0) {
    [unowned self] (postion, rotation) in
            
    self.rocketImageView.center = postion
            
    let rocketRotation = CGFloat(rotation.value)
    self.rocketImageView.transform = CGAffineTransform(rotationAngle: rocketRotation)
}
    
action.easing = .exponentialInOut
        
scheduler.run(action: action)
```

당연히에러가 발생. path변수 설정이 필요하고 로켓이미지도 에셋에 추가

path, bound에 대한 처리가 필요 (샘플9. RocketView 참고)

```swift
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

    scheduler.run(action: repeatedAction)

}
```

### Scrubbable actions

해당 함수를 사용해서 full slider를 통해서도 백그라운드를 변경 시킬수 있을지

1. add slider and scrubbable and sliderValueChanged func

    ```swift
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
    ```

1. action setting sequence

    ```swift
    //Scrubbable
    actionScrubber = ActionScrubber(action: action)
    ```
