import UIKit
import WebKit

class QRScannerViewController: UIViewController {
    @IBOutlet weak var labelDetail: CopyLabel!
    @IBOutlet weak var navigation: UINavigationItem!
    
    @IBOutlet weak var scanText: UILabel!
    @IBOutlet weak var language: UIButton!
    @IBOutlet weak var homeButtonBorder: UIButton!
    @IBOutlet weak var cameraRotate: UIView!
    @IBOutlet var webViews: WKWebView!
    @IBOutlet weak var scannerView:
        
        QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    @IBOutlet weak var scanButton: UIButton! {
        didSet {
            scanButton.setTitle("STOP", for: .normal)
        }
    }
    
    var qrData: QRData? = nil {
        didSet {
            if qrData != nil {
                self.performSegue(withIdentifier: "detailSeuge", sender: self)
            }
        }
    }
    var spanish = false
    override func viewDidLoad() {
        super.viewDidLoad()
        homeButtonBorder.layer.borderWidth = 5
        homeButtonBorder.layer.borderColor = UIColor.white.cgColor
        self.navigation.title = ""
        scannerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    @IBAction func homeButton(_ sender: Any) {
        self.qrData = QRData(codeString: "https://rondevunc.com/")
    }
    
    @IBAction func languageChange(_ sender: Any) {
        spanish = !spanish
        if (spanish) {
//        language.setTitle("English", for: .normal)
        homeButtonBorder.setTitle("Hogar", for: .normal)
            let backButton = UIBarButtonItem()
            backButton.title = "Escanear código QR"
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
            self.scanText?.text = "Escanee el código QR para ver medidas y precios!"
        }
        else {
//            language.setTitle("Espanol", for: .normal)
            
            homeButtonBorder.setTitle("Home", for: .normal)
            self.scanText?.text = "Scan QR code to view sizes and prices!"
            let backButton = UIBarButtonItem()
            backButton.title = "Scan QR code"
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }

    @IBAction func scanButtonAction(_ sender: UIButton) {
        scannerView.isRunning ? scannerView.stopScanning() : scannerView.startScanning()
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        sender.setTitle(buttonTitle, for: .normal)
    }
}


extension QRScannerViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        scanButton.setTitle(buttonTitle, for: .normal)
    }
    
    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        self.qrData = QRData(codeString: str)
    }
    
    
    
}


extension QRScannerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSeuge", let viewController = segue.destination as? DetailViewController {
            viewController.qrData = self.qrData
        }
    }
}

