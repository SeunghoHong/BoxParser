//
//  ViewController.swift
//  BoxParser
//
//  Created by HongSeungho on 8/26/16.
//  Copyright © 2016 INISoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let dataSource: DataSource = FileSource(uri: "/Users/seunghohong/Downloads/Sample/SuperSpeedway_720_230_enc.ismv") {
            let boxParser: Parser = BoxParser(dataSource: dataSource)
            boxParser.parse()
        }
        if let dataSource: DataSource = HTTPSource(uri: "http://playready.directtaps.net/smoothstreaming/SSWSS720H264/SuperSpeedway_720_230.ismv") {
            let boxParser: Parser = BoxParser(dataSource: dataSource)
            boxParser.parse()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

