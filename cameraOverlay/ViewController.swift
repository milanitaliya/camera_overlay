
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Camera overlay view
    var cameraView: UIView!
    
    // Camera object
    let myCamera = UIImagePickerController()
    
    // Image object used to pass the captured image for previewing
    var image: UIImage! = nil
    @IBOutlet weak var capturedImage: UIImage!

    @IBAction func captureBtnWasPressed(_ sender: Any) {
        cameraView = UIView()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            if UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera) != nil{
                // Use front camera and add overlay on it
                myCamera.sourceType = .camera
                myCamera.cameraDevice = .front
                myCamera.delegate = self
                myCamera.showsCameraControls = false
                myCamera.cameraOverlayView = self.addOverlay()
                self.present(myCamera, animated: false, completion: nil)
            }
        }else{
            print("no camera device found")
        }
    }
    
    // Capture the image and show it on PreviewImageViewController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        myCamera.dismiss(animated: false, completion: {
            
            
            self.capturedImage = info[.originalImage] as? UIImage
            
            if(self.capturedImage != nil){
                
                let capturedImageFlipped = UIImage(cgImage: self.capturedImage.cgImage!, scale: 1.0, orientation: .leftMirrored)

                let overlay = self.getImageOverlay()
                
                let size = capturedImageFlipped.size
                
                UIGraphicsBeginImageContext(size)

                let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                capturedImageFlipped.draw(in: areaSize)

                overlay.image!.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

                let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)

            }
            
        })
    }
        //MARK: - Add image to Library
            @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
                if error != nil {
                    // we got back an error!
                    showAlertWith(title: "Save error", message: error?.localizedDescription)
                } else {
                    showAlertWith(title: "Saved", message: "Your image has been saved to your photos")
                }
            }
    
    func showAlertWith(title: String?, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    // Shoot the camera!
    @IBAction func didPressShootButton(){
        myCamera.takePicture()
    }
    
    // Used to skip the taking picture step when the camera is open
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        myCamera.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "nextPageSegue", sender: nil)
        })
    }
    
    
    func addCameraButton(_ cameraView: UIView){
        let screenBounds: CGSize = UIScreen.main.bounds.size;

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "camera"), for: .normal)
        button.isUserInteractionEnabled = true
        button.frame = CGRect(x: screenBounds.width/2 - 45, y: screenBounds.height - 90, width: 90, height: 90)
        button.addTarget(self, action: #selector(self.didPressShootButton), for: .touchUpInside)
        cameraView.addSubview(button)
        
    }
    
    func addImageOverlay(_ cameraView: UIView){
        
        let overlay = getImageOverlay()
        cameraView.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor).isActive = true
        overlay.leftAnchor.constraint(equalTo: cameraView.leftAnchor).isActive = true
        overlay.rightAnchor.constraint(equalTo: cameraView.rightAnchor).isActive = true

    }
    
    func getImageOverlay() -> UIImageView{
        
        let screenBounds: CGSize = UIScreen.main.bounds.size;
        let frame           = CGRect.init(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height)
        let overlay         = UIImageView.init(frame: frame)
        overlay.contentMode = .scaleAspectFit
        overlay.image       = UIImage(named: "overlay")  // Just an example.
        
        return overlay

    }

    func addOverlay() -> UIView? {
        self.addImageOverlay(cameraView)
        self.addCameraButton(cameraView)
        
        cameraView.frame = self.view.frame
        return cameraView
    }
}
