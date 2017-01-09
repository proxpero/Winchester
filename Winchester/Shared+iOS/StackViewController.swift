//
//  StackViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 1/3/17.
//  Copyright © 2017 Todd Olsen. All rights reserved.
//

import UIKit

//public enum ContentElement {
//    case board(String)
//    case button(String, () -> ())
//    case image(UIImage)
//}
//
//extension ContentElement {
//    var view: UIView {
//        switch self {
//        case .label(let text):
//            let label = UILabel()
//            label.numberOfLines = 0
//            label.text = text
//            return label
//        case .button(let title, let callback):
//            return CallbackButton(title: title, onTap: callback)
//        case .image(let image):
//            return UIImageView(image: image)
//        }
//    }
//}

//extension UIStackView {
//    public convenience init(elements: [ContentElement]) {
//        self.init()
//        translatesAutoresizingMaskIntoConstraints = false
//        axis = .Vertical
//        spacing = 10
//
//        for element in elements {
//            addArrangedSubview(element.view)
//        }
//    }
//}

open class StackViewController: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let stack = UIStackView()
        view.addSubview(stack)
        stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        stack.constrainEqual(.width, to: view)
//        stack.constrainEqual(.top, to: view)
//        stack.center(in: view)
        
    }
}

