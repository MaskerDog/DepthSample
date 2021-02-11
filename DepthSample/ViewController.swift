//
//  ViewController.swift
//  DepthSample
//
//  Created by npc on 2021/02/11.
//

// 注意事項
// iOS14以降で動作
// 写真はポートレートで撮影すること

// 最初にやること
// Privacy - Photo Library Usage Descriptionと
// Privacy - Photo Library Additions Usage Descriptionをplistに追加する

// MARK: -
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var selectedPhotoImageView: UIImageView!
    
    private var mattePixelBuffer: CVPixelBuffer?
    
    private var selectedImageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // アラート表示
        
        let alertController = UIAlertController(title: "注意事項", message: "ポートレートモードで撮影した写真を使ってください", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    private func drawImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.selectedPhotoImageView.image = image
        }
    }
    
    private func setMattePixelBuffer(cgImageSource: CGImageSource) {
        var depthDataMap: CVPixelBuffer? = nil
        if let matteData = cgImageSource.effectMatte {
            depthDataMap = matteData.mattingImage
        }
        mattePixelBuffer = depthDataMap
    }
    
    // MARK: - IBActions
    @IBAction func tappedSelectPhoto(_ sender: UIButton) {
        // 許可されているならば写真を取得する
        PhotoLibraryAuthorization.ifAuthorizingExecute {
            DispatchQueue.main.async {
                let pickerView = UIImagePickerController()
                pickerView.sourceType = .photoLibrary
                pickerView.delegate = self
                self.present(pickerView, animated: true)
            }
        }
    }
    
    @IBAction func tappedAcademic(_ sender: UIButton) {
        
        if let url = selectedImageURL {
            setMattePixelBuffer(cgImageSource: CGImageSourceCreateWithURL(url as CFURL, nil)!)
            
            
            guard let image = UIImage(contentsOfFile: url.path) else { fatalError() }
            
            
            guard let cgImage = image.cgImage else { return }
            guard let matte = mattePixelBuffer else {
                info("matteが取得できていない")
                return
            }
            let ciImage = CIImage(cgImage: cgImage)
            let maskImage = CIImage(cvPixelBuffer: matte).makeSameSize(as: ciImage)
            let filter = CIFilter(name: "CIBlendWithMask", parameters: [
                                    kCIInputImageKey: ciImage,
                                    kCIInputMaskImageKey: maskImage])!
            let outputImage = filter.outputImage!
            drawImage(UIImage(ciImage: outputImage))
        }
        
        
    }
}

// MARK: - extension
extension ViewController: UIImagePickerControllerDelegate {
    // 写真選択後の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageURL = info[.imageURL] as? URL {

            selectedImageURL = imageURL

        }
        
        if let image = info[.originalImage] as? UIImage {
            selectedPhotoImageView.image = image
            dismiss(animated: true, completion: nil)
        } else {
            error("写真が取得できない")
        }
        
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}


// TODO: - 後で分離する

// AVDepthDataで使う
import AVFoundation

extension CGImageSource {
    
    var effectMatte: AVPortraitEffectsMatte? {
        if let info = CGImageSourceCopyAuxiliaryDataInfoAtIndex(self, 0, kCGImageAuxiliaryDataTypePortraitEffectsMatte) as? [String : AnyObject] {
            
            return try? AVPortraitEffectsMatte(fromDictionaryRepresentation: info)
        }
        return nil
    }
    
    
    var depthData: AVDepthData? {
        if let depthDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(self, 0, kCGImageAuxiliaryDataTypeDepth) as? [String : AnyObject] {
            
            if let avDetphData =  try? AVDepthData(fromDictionaryRepresentation: depthDataInfo) {
                return avDetphData
            }
            
        } else if let displayDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(self, 0, kCGImageAuxiliaryDataTypeDisparity) as? [String : AnyObject] {
            if let avDepthData = try? AVDepthData(fromDictionaryRepresentation: displayDataInfo) {
                
                switch avDepthData.depthDataType {
                case kCVPixelFormatType_DisparityFloat16:
                    return avDepthData.converting(toDepthDataType: kCVPixelFormatType_DepthFloat16)
                case kCVPixelFormatType_DisparityFloat32:
                    return avDepthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
                default:
                    return avDepthData
                }
            }
        }
        return nil
    }
}


extension CIImage {
    
    func makeSameSize(as differentImage: CIImage) -> CIImage {
        let selfSize = extent.size
        let otherSize = differentImage.extent.size
        
        let transform = CGAffineTransform(scaleX: otherSize.width / selfSize.width, y: otherSize.height / selfSize.height)
        return transformed(by: transform)
    }
}
