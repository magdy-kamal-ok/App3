//
//  Extensions.swift
//  YouTubeApp
//
//  Created by magdy on 3/27/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)->UIColor{
        
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

extension UIView {
    
    func addConstraintWithFormat(format:String,views:UIView...)
    {
        var viewsDictionary = [String:UIView]()
        for(index,view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

let imageCash = NSCache<AnyObject, AnyObject>()
class CustomImageView:UIImageView {
    
    var imageUrlString:String?
    func loadImageUsingUrlString(urlString:String)
    {
           self.image = nil
           let url = NSURL(string: urlString)
           imageUrlString = urlString
        
           if let imageFromCash = imageCash.object(forKey: urlString as AnyObject) as? UIImage
           {
                self.image = imageFromCash
                return
            
           }
           URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            
                if error != nil {
                    print(error)
                    return
                }
                DispatchQueue.main.async(execute: {
                    let imageToCashe = UIImage(data: data!)
                    imageCash.setObject(imageCash, forKey: urlString as AnyObject)
                    if self.imageUrlString == urlString {
                        self.image = imageToCashe
                    }
                })
            }.resume()
        
    }

}
