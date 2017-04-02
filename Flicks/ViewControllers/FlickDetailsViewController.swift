//
//  FlickDetailsViewController.swift
//  Flicks
//
//  Created by Pattanashetty, Sadananda on 4/1/17.
//  Copyright © 2017 Pattanashetty, Sadananda. All rights reserved.
//

import UIKit

class FlickDetailsViewController: UIViewController {


    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var flickTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var releaseDt: UILabel!
    @IBOutlet weak var descText: UITextView!

    var viewModel: FlickDetailsViewModel?

        override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        load()
    }

    func load() {
        guard let viewModel = self.viewModel else {
            return
        }

        if let url = viewModel.posterUrl() {
            posterImg.setImageWith(url)
        }

        flickTitle.text = viewModel.movie.title
        duration.text = String(describing: viewModel.movie.popularity!)
        releaseDt.text = viewModel.movie.release_date
        descText.text = viewModel.movie.overview
        
    }

}
