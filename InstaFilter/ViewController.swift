//
//  ViewController.swift
//  InstaFilter
//
//  Created by Shah Md Imran Hossain on 15/10/22.
//

import CoreImage
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    @IBOutlet weak var changeFilterButton: UIButton!
    
    var currentImage: UIImage!
    var filterNames = [String]()
    
    // CIConext - Core Image Context
    // This is a Core image component which handles rendering
    // we will create it once and use it throughout our app with it's property
    // because creating context is computationally expensive
    var context: CIContext!

    // CIFilter - Core Image Filter
    // store user activated filter
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        filterNames = ["CISepiaTone", "CIGaussianBlur", "CIBumpDistortion", "CITwirlDistortion", "CIPixellate", "CISharpenLuminance", "CIUnsharpMask", "CIVignette", "CIColorPolynomial", "CIDarkenBlendMode"]
        
        title = "Insta Filter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        // CISepiaTone is a core image filter name
        currentFilter = CIFilter(name: filterNames[0])
        changeFilterButton.setTitle(filterNames[0], for: .normal)
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        // adding filter to the list
        for name in filterNames {
            ac.addAction(UIAlertAction(title: name, style: .default, handler: setFilter))
        }
        
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else {
            print("current image is nil")
            return
        }
        
        guard let actionTitle = action.title else {
            print("action title is nil")
            return
        }
        
        currentFilter = CIFilter(name: actionTitle)
        changeFilterButton.setTitle(actionTitle, for: .normal)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let imageContent = imageView.image else {
            let ac = UIAlertController(title: "No Image!!!", message: "Image view has no image", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageContent, self, #selector(image(_: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            // input intensity key for intensity value changed
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else {
            print("output image is nil")
            return
        }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("creating cgImage failed")
            return
        }
        
        let processedImage = UIImage(cgImage: cgImage)
        imageView.image = processedImage
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let ac: UIAlertController!
        
        if let  error = error {
            ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
        } else {
            ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
        }
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("edited image casting failed")
            return
        }
        
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        // input image key
        // when inputing image for filter
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
    
}
