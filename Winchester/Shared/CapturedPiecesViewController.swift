//
//  CapturedPiecesViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 10/31/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

public final class CapturedPiecesViewController: ViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let skview = self.view as? CapturedPiecesView else { fatalError("ERROR: Expected a CapturedView") }
        let scene = SKScene()
        scene.backgroundColor = UIColor.clear
        scene.scaleMode = .aspectFill
        scene.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        skview.presentScene(scene)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let skview = self.view as? CapturedPiecesView, let scene = skview.scene else { fatalError("ERROR: Expected a CapturedView") }
        scene.size = view.bounds.size
        skview.pieceSize = CGSize(edge: (scene.size.area()/16.0).squareRoot())
        skview.presentScene(scene)
        skview.setup()
    }

}
