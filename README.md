## TweenKit 라이브러리 사용법.
원본 깃을 참고하면 좋음, 리드미파일과 샘플 파일을 비교하면서 확인해보자.
[TweenKit](https://github.com/SteveBarnegren/TweenKit)

### Hello World
```
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
```

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
```
let repeat2 = moveAndChangeColor.yoyo().repeatedForever()

schedular2.run(action: repeat2)
  ```
  //스케쥴러는 어떤거를 사용해도 상관이 없음
  //대신 각각의 애니메이션이 사용하는 뷰는 하나의 애니메이션당 하나의 뷰가 필요함.
  //예를 들어 첫번째 애니메이션과 두번째 애니메이션이 같은 뷰를 사용한다면, 나중에 실행된 애니메이션의 액션이 뷰를 통해 실행됨.
