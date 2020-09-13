//
//  FileChooser.swift
//  Q8ForSale
//
//  Created by Magdy Kamal on 7/9/20.
//  Copyright © 2020 Condor Tech. All rights reserved.
//

import UIKit
import MobileCoreServices

class FileChooser: NSObject, UIDocumentPickerDelegate , UIDocumentMenuDelegate, UINavigationControllerDelegate {
    
    var selectionCompletion: ((_ fileName: String, _ type: String, _ localUrl: String, _ fileData: Data?) -> Void)?
    weak var viewController: UIViewController?
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        viewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    func chooseFile() {
        let docTypes = [kUTTypePDF , kUTTypePNG , kUTTypeImage , kUTTypeJPEG]
        let importMenu = UIDocumentPickerViewController(
            documentTypes: docTypes as [String],
            in: .import)

        importMenu.delegate = self
        viewController?.present(importMenu, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .import {
            let fileName = url.lastPathComponent
            let fileType = url.lastPathComponent.components(separatedBy: ".").last
            let urlString = url.absoluteString
            var fileData: Data? = nil
            url.startAccessingSecurityScopedResource()
            if FileManager.default.fileExists(atPath: url.path) {
                if let data = NSData(contentsOfFile: url.path) {
                    fileData = data as Data
                }
            }
            
            selectionCompletion?(fileName, fileType ?? "", urlString, fileData)
            url.stopAccessingSecurityScopedResource()
        }
    }
}

