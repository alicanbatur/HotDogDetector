//
//  ViewController.swift
//  hotdog
//
//  Created by Ali Can Batur on 08/06/2017.
//  Copyright © 2017 alikoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private struct Colors {
        static let succeed = UIColor(red: 0.05882, green: 0.6863, blue: 0.01176, alpha: 1.0)
        static let failed = UIColor(red: 0.6863, green: 0.01176, blue: 0.01176, alpha: 1.0)
    }
    
    var vgg: VGG16 {
        return VGG16()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Is that a hotdog?"
        informationLabel.text = ""
        activityIndicator.isHidden = true
    }
    
    // MARK: - Private Funcs
    
    private func classify(image: UIImage) {
        guard let buffer = image.asPixelBuffer() else { return }
        do {
            let answer = try vgg.prediction(image: buffer)
            shouldPopulateUIasHotDog(isThatHotDog(classLabel: answer.classLabel))
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func takePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func isThatHotDog(classLabel: String) -> Bool {
        return classLabel.contains("hotdog") || classLabel.contains("hot dog")
    }
    
    private func shouldPopulateUIasHotDog(_ isHotDog: Bool) {
        if isHotDog {
            informationLabel.text = "YES 🎉"
            informationLabel.textColor = Colors.succeed
        } else {
            informationLabel.text = "NO ☹️"
            informationLabel.textColor = Colors.failed
        }
        shouldShowIndicator(false)
    }
    
    func shouldShowIndicator(_ show: Bool) {
        takePhotoButton.isHidden = show
        activityIndicator.isHidden = !show
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapChoosePhoto(_ sender: Any) {
        takePicture()
        shouldShowIndicator(true)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        shouldShowIndicator(false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        imageView.image = image
        dismiss(animated: true) {
            self.classify(image: image)
        }
    }
    
}

extension ViewController: UINavigationControllerDelegate {}
