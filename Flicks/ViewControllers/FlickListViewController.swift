//
//  FlickListViewController.swift
//  Flicks
//
//  Created by Pattanashetty, Sadananda on 4/1/17.
//  Copyright © 2017 Pattanashetty, Sadananda. All rights reserved.
//

import UIKit
import AFNetworking
import FTIndicator

class FlickListViewController: UIViewController {

    @IBOutlet weak var flicksTableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerLabel: UILabel!

    var viewModel: FlickListViewModel!
    let refreshCtrl = UIRefreshControl()
    var scrollerFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.banner(show: false)

        self.viewModel = FlickListViewModel()

        initDataManager()
        refreshCtrl.addTarget(self, action: #selector(refreshTable(_:)), for: UIControlEvents.valueChanged)
        flicksTableView.insertSubview(refreshCtrl, at: 0)
    }

    func initDataManager() {
        DataManager.sharedInstance.delegate = self
        viewModel.fetchData(freshLoad: true)
        FTIndicator.showProgressWithmessage("Fetching movies..")

    }

    func refreshTable(_ sender: UIRefreshControl? = nil) {
        addTableFooter()
        viewModel.fetchData()
    }

    func banner(show: Bool, message: String = "") {
        self.bannerView.alpha = 0
        self.bannerView.isHidden = !show
        self.bannerLabel.text = message

        if show {
            let maxy = self.bannerView.frame.maxY
            let miny = self.bannerView.frame.minY
            let y = self.bannerView.frame.origin.y

            self.bannerView.frame.origin.y = y - (maxy-miny)
            self.bannerView.alpha = 1.0

            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.bannerView.frame.origin.y = y
            })

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedRow = self.flicksTableView.indexPathForSelectedRow
        let detailsViewController = segue.destination as! FlickDetailsViewController
        detailsViewController.viewModel = FlickDetailsViewModel(movie: self.viewModel.movieForIndexPath(index: selectedRow!)!)
    }

    func addTableFooter() {
        let tableFooterView: UIView = UIView()
        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingView.startAnimating()
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)
        self.flicksTableView.tableFooterView = tableFooterView
    }

}

extension FlickListViewController : DataManagerListener {

    func finishedFetchingData(result : FetchResult) {

        switch result {
            
        case .Success(let movies):
            self.viewModel = FlickListViewModel(movies: movies)
            flicksTableView.reloadData()
            self.bannerView.isHidden = true
            
        case .Failure(let errorStr):
            NSLog(errorStr)
            self.banner(show: true, message: "No Network Connection!")

        }

        refreshCtrl.endRefreshing()
        FTIndicator.dismissProgress()
        self.scrollerFlag = false
    }
}

extension FlickListViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.flicks.list.cell", for: indexPath) as! MovieCell

        if let movie = viewModel.movieForIndexPath(index: indexPath) {
            cell.movieTitle.text = movie.title! as String
            cell.movieTitle.sizeToFit()
            cell.movieDesc.text = movie.overview! as String
            cell.movieDesc.sizeToFit()

            if let posterUrl = movie.poster_path {
                let baseUrl = "http://image.tmdb.org/t/p/w342"
                cell.loadImage(imageUrl: baseUrl + (posterUrl as String))
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.isDataAvailable() {
            return viewModel.moviesCount()
        }
        return 0
    }

    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "flickDetailsViewController") as! FlickDetailsViewController

        vc.viewModel = FlickDetailsViewModel(movie: self.viewModel.movieForIndexPath(index: indexPath)!)
        self.navigationController?.pushViewController(vc, animated: true)
    }*/

}

extension FlickListViewController : UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if !self.scrollerFlag {
            let scrollViewContentHeight = flicksTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - flicksTableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && flicksTableView.isDragging) {
                DataManager.sharedInstance.fetchMoviesData()
                self.scrollerFlag = true
            }
        }
    }
}

class MovieCell : UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieDesc: UITextView!

    func loadImage(imageUrl : String) {

        let imageRequest = URLRequest(url: URL(string: imageUrl)! )

        self.moviePoster.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                   if imageResponse != nil {
                     self.moviePoster.alpha = 0.0
                    self.moviePoster.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.moviePoster.alpha = 1.0
                    })
                } else {
                     self.moviePoster.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
        })
    }
}


