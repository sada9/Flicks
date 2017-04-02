//
//  DataManager.swift
//  Flicks
//
//  Created by Pattanashetty, Sadananda on 4/1/17.
//  Copyright © 2017 Pattanashetty, Sadananda. All rights reserved.
//

import Foundation
import AFNetworking

protocol DataManagerListener {
    func finishedFetchingData(result : FetchResult)
}

enum FetchResult {
    case Success([Movie])
    case Failure(String)
}
class DataManager {

    static var sharedInstance = DataManager()
    fileprivate let manager = AFHTTPSessionManager()
    var delegate: DataManagerListener?
    var moviesPages: [MoviesPage] = []
    var currentPage: Int = 0
    var movies: [Movie] = []


    func fetchMoviesData(){

        let requestURL = "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&page=\(currentPage+1)"

        manager.get(requestURL, parameters: nil,
                    progress: { (progress : Progress ) -> Void in NSLog("--") }
                ,success:  {
                (dataTaskSession: URLSessionDataTask, data: Any) in
                let moviePage = MoviesPage(data: data as! NSDictionary)
                self.currentPage = moviePage.page!
                self.moviesPages.append(moviePage)
                self.setMovies()

                if let delegate = self.delegate {
                    delegate.finishedFetchingData(result: FetchResult.Success(self.movies) )
                }
                NSLog("Fetched data for page: \(self.currentPage)")
            },

             failure: { (date: URLSessionDataTask?, error: Error) -> Void in

                if let delegate = self.delegate {
                    delegate.finishedFetchingData(result: FetchResult.Failure(error.localizedDescription))
                }
            }
        )
    }

    func setMovies() {
        for page in moviesPages {
            self.movies.append(contentsOf: page.results)
        }
    }


}

struct MoviesPage {
    var page: Int?
    var results: [Movie] = []
    var dates: Any?
    var total_pages: Int?
    var total_results: Int?

    init(data: NSDictionary) {
        page = data["page"] as? Int
        let movieArray = data["results"] as! NSArray

        for movieItem in movieArray {
            let movie = Movie(data: movieItem as! NSDictionary)
            results.append(movie)
        }

    }
}

struct Movie {
    var poster_path: String?
    var adult: Bool?
    var overview: String?
    var release_date: String?
    var genre_ids: [Int]?
    var id: Int?
    var original_title:  String?
    var original_language:  String?
    var title:  String?
    var backdrop_path:  String?
    var popularity: Int?
    var vote_count: Int?
    var video: Bool?
    var vote_average: Int?

     init(data: NSDictionary) {

        if let poster_path = data["poster_path"] {
            self.poster_path = String(describing: poster_path)
        }

        if let adult = data["adult"] {
            self.adult = adult as? Bool
        }

        if let overview = data["overview"] {
            self.overview = String(describing: overview)
        }

        if let release_date = data["release_date"] {
            self.release_date = String(describing: release_date)
        }

        if let id = data["id"] {
            self.id = id as? Int
        }

        if let original_title = data["original_title"] {
            self.original_title = String(describing: original_title)
        }

        if let original_language = data["original_language"] {
            self.original_language = String(describing: original_language)
        }

        if let title = data["title"] {
            self.title = String(describing: title)
        }

        if let backdrop_path = data["backdrop_path"] {
            self.backdrop_path = String(describing: backdrop_path)
        }

        if let popularity = data["popularity"] {
            self.popularity = popularity as? Int
        }

        if let vote_count = data["vote_count"] {
            self.vote_count = vote_count as? Int
        }

        if let vote_average = data["vote_average"] {
            self.vote_average = vote_average as? Int
        }

        if let video = data["video"] {
            self.video = video as? Bool
        }
    }
}
