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
    @IBOutlet weak var flicksCollectionView: UICollectionView!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!

    var viewModel: FlickListViewModel!
    let refreshCtrl = UIRefreshControl()
    var scrollerFlag = false


    override func viewDidLoad() {
        super.viewDidLoad()
        self.banner(show: false)

        self.viewModel = FlickListViewModel()
        self.edgesForExtendedLayout = []

        initDataManager()
        refreshCtrl.addTarget(self, action: #selector(refreshTable(_:)), for: UIControlEvents.valueChanged)
        flicksTableView.insertSubview(refreshCtrl, at: 0)
        searchBar.delegate = self

        definesPresentationContext = true
    }

    func initDataManager() {
        DataManager.sharedInstance.delegate = self
        viewModel.fetchData(freshLoad: true)
        FTIndicator.showProgressWithmessage("Fetching movies..")

    }

    func refreshTable(_ sender: UIRefreshControl? = nil) {

        addTableFooter()
        viewModel.fetchData(freshLoad: true)
    }

    func banner(show: Bool, message: String = "") {
        self.bannerView.alpha = 0
        self.bannerView.isHidden = !show
        self.bannerLabel.text = message


        if show {
            let maxy = 91.0 //self.bannerView.frame.maxY //91
            let miny = 63.0 // self.bannerView.frame.minY //63
            let y = 63.0 //self.bannerView.frame.origin.y //63

            self.bannerView.frame.origin.y = CGFloat(y - (maxy-miny) - 25)
            self.bannerView.alpha = 1.0

            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.bannerView.frame.origin.y = CGFloat(y - 25)
            })

        }
    }

    @IBAction func segmentIndexChanged(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            flicksTableView.isHidden = false
            flicksCollectionView.isHidden = true
        }
        else{
            flicksTableView.isHidden = true
            flicksCollectionView.isHidden = false
            flicksCollectionView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        var indexPath: IndexPath!

        if(self.segmentView.selectedSegmentIndex == 0){
            indexPath = self.flicksTableView.indexPathForSelectedRow
        }
        else {
            indexPath = self.flicksCollectionView.indexPathsForSelectedItems?[0]
        }

        let detailsViewController = segue.destination as! FlickDetailsViewController
        detailsViewController.viewModel = FlickDetailsViewModel(movie: self.viewModel.movieForIndexPath(index: indexPath!)!)

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

extension FlickListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filterContentForSearchText(searchController.searchBar.text!)
        let movies = viewModel.filterFlicks(key: searchText)
        if movies.count > 0 {
            self.finishedFetchingData(result: .Success(movies))
        }
    }

    func searchBarTextDidBeginEditing(_ search: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ search: UISearchBar) {
        search.showsCancelButton = false
        search.text = ""
        search.resignFirstResponder()

        viewModel.fetchData(freshLoad: true)
    }

}



extension FlickListViewController : DataManagerListener {

    func finishedFetchingData(result : FetchResult) {

        switch result {
            
        case .Success(let movies):
            self.viewModel = FlickListViewModel(movies: movies)
            flicksTableView.reloadData()
            flicksCollectionView.reloadData()
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

extension FlickListViewController :  UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell

        if let movie = viewModel.movieForIndexPath(index: indexPath) {
            if let posterUrl = movie.poster_path {
                let baseUrl = "http://image.tmdb.org/t/p/w342"
                cell.loadImage(imageUrl: baseUrl + (posterUrl as String))
            }
        }
        return cell


    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.viewModel.isDataAvailable() {
            return viewModel.moviesCount()
        }
        return 0
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

extension FlickListViewController : UIScrollViewDelegate{

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if !self.scrollerFlag {
            if self.segmentView.selectedSegmentIndex == 0 {
                let scrollViewContentHeight = flicksTableView.contentSize.height
                let scrollOffsetThreshold = scrollViewContentHeight - flicksTableView.bounds.size.height

                if(scrollView.contentOffset.y > scrollOffsetThreshold && flicksTableView.isDragging) {
                    DataManager.sharedInstance.fetchMoviesData()
                    self.scrollerFlag = true
                }
            }
            else {
                let scrollViewContentHeight = flicksCollectionView.contentSize.height
                let scrollOffsetThreshold = scrollViewContentHeight - flicksCollectionView.bounds.size.height

                // When the user has scrolled past the threshold, start requesting
                if(scrollView.contentOffset.y > scrollOffsetThreshold && flicksCollectionView.isDragging) {
                    DataManager.sharedInstance.fetchMoviesData()
                    self.scrollerFlag = true
                }
            }
        }
    }
}

class MovieCollectionCell : UICollectionViewCell {

    @IBOutlet weak var flickPoster: UIImageView!

    func loadImage(imageUrl : String) {

        let imageRequest = URLRequest(url: URL(string: imageUrl)! )
        self.flickPoster.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    self.flickPoster.alpha = 0.0
                    self.flickPoster.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.flickPoster.alpha = 1.0
                    })
                } else {
                    self.flickPoster.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
        })
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


