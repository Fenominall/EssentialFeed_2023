//
//  ErrorView.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 11/21/23.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get {return label.text }
        set {label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
}
