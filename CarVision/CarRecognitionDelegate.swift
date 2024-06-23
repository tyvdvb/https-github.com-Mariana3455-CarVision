//
//  CarRecognitionDelegate.swift
//  CarVision
//
//  Created by Mariana Dekhtiarenko on 23.06.2024.
//

import Foundation
import UIKit

protocol CarRecognitionDelegate: AnyObject {
    func didRecognizeCar(model: String, image: UIImage)
}
