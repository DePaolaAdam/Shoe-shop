import WebKit
import UIKit

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var backButton: UINavigationItem!
    @IBOutlet weak var detailLabel: CopyLabel!
    @IBOutlet weak var scannerViewer:      QRScannerView! {
        didSet {
            scannerViewer.delegate = self
        }
    }
    @IBOutlet weak var tsm: UILabel!
    @IBOutlet weak var centerView: UIView!

    @IBOutlet weak var webView: WKWebView!
    var qrData: QRData?
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        scannerViewer.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//        self.navigationController!.navigationBar.topItem!.title = "broBack";
//        resetTimer()
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.resetTimer))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.resetTimer))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DetailViewController.resetTimer))
        swipeGesture.direction = [.down, .up]
        swipeGesture.delegate = self
//        tapGesture.delegate = self
        webView.isUserInteractionEnabled = true
        tapGesture.delegate = self
        webView.addGestureRecognizer(tapGesture)
    webView.addGestureRecognizer(swipeGesture)
//        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DetailViewController.goBack), userInfo: nil, repeats: true)
//        let resetTimer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.resetTimer));
//        self.view.isUserInteractionEnabled = true
//        self.view.addGestureRecognizer(resetTimer)
//
        detailLabel.text = String((qrData?.codeString)!)
        
            let buttonFrame = CGRect(x: 50, y: 150, width: 50, height: 50)
            let button = UIButton(frame: buttonFrame)
            self.view.addSubview(button)
//        let wvHeight = self.view.frame.height - 40
//        self.webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: wvHeight))

//        self.webView.autoresizingMask = [.width, .height]
//        self.view.addSubview(self.webView)
        
        var myURL = URL(string: String(detailLabel.text!))
        if(String(detailLabel.text!.prefix(4)) == "URL:")
        {
            myURL = URL(string: String(detailLabel.text!.dropFirst(4)))
        }
        else {
            myURL = URL(string: String(detailLabel.text!))
        }
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
    @objc func goBack() {
       // perform any action you wish to
        _ = navigationController?.popToRootViewController(animated: true)
        self.timer.invalidate()
    }
    @objc func resetTimer() {
        timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 45, target: self, selector: #selector(DetailViewController.goBack), userInfo: nil, repeats: true)
    }
    @IBAction func openInWebAction(_ sender: Any) {
        if let url = URL(string: qrData?.codeString ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            showToast(message : "Not a valid URL")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !scannerViewer.isRunning {
            scannerViewer.startScanning()
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if !scannerViewer.isRunning {
//            scannerViewer.stopScanning()
//        }
//    }

    @IBAction func scanButtonAction(_ sender: UIButton) {
        scannerViewer.isRunning ? scannerViewer.stopScanning() : scannerViewer.startScanning()
        let buttonTitle = scannerViewer.isRunning ? "STOP" : "SCAN"
        sender.setTitle(buttonTitle, for: .normal)
    }
}
extension DetailViewController: QRScannerViewDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }
    func qrScanningDidStop() {
        _ = scannerViewer.isRunning ? "STOP" : "SCAN"
    }


    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }

    func qrScanningSucceededWithCode(_ str: String?) {
        self.qrData = QRData(codeString: str)
        var myURL = URL(string: String(detailLabel.text!))
        if(String(detailLabel.text!.prefix(4)) == "URL:")
        {
            myURL = URL(string: String(str!.dropFirst(4)))
        }
        else {
            myURL = URL(string: String(str!))
        }
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        scannerViewer.startScanning()
    }
}
