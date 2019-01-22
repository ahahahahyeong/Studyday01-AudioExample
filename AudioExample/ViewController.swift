
import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate {
    
    // MARK: - Properties
    var player : AVAudioPlayer!
    var timer : Timer!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    //플레이어 초기화 메소드
    func initializePlayer() {
        guard let soundAsset : NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원파일 에셋을 가져올 수 없습니다.")
            return
        }
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드: \(error.code), 메시지:\(error.localizedDescription) ")
        }
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
    }
    
    //레이블을 매 초마다 업데이트 해주는 메소드
    func updateTimeLableText(time : TimeInterval) {
        let minute : Int = Int(time/60)
        let second : Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond : Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText : String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        self.timeLabel.text = timeText
    }
    
    //타이머를 만들고 수행하는 메소드
    func makeAndFireTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned
            self] (timer: Timer) in
            if self.progressSlider.isTracking { return }
            self.updateTimeLableText(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error : Error = error else {
            print("디코드 오류 발생")
            return
        }
        let message : String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert : UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction : UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil )
        }
        alert.addAction(okAction)
        self.present(alert,animated: true,completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLableText(time: 0)
        self.invalidateTimer()
    }
    //타이머 해제 메소드
    func invalidateTimer(){
        self.timer.invalidate()
        self.timer = nil
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializePlayer()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func touchUpPlayPauseButton(_ sender : UIButton){
        print("플레이버튼 터치 메소드 실행 ")
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
        }else {
            self.player?.pause()
        }
        
        if sender.isSelected {
            self.makeAndFireTimer()
        }else {
            self.invalidateTimer()
        }
        
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("슬라이더 터치 메소드 실행")
        self.updateTimeLableText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
    }
}

