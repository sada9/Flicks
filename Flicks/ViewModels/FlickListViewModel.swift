//
//  FlickListViewModel.swift
//  Flicks
//
//  Created by Pattanashetty, Sadananda on 4/1/17.
//  Copyright © 2017 Pattanashetty, Sadananda. All rights reserved.
//

import Foundation

class FlickListViewModel {
    var movies: [Movie]?

    convenience init(movies: [Movie]?) {
        self.init()
        self.movies = movies
    }

    init () {
        self.movies = nil
    }
        
    func moviesCount() -> Int {
        return (movies?.count)!
    }

    func movieForIndexPath(index : IndexPath) -> Movie? {

        guard let movie = movies?[index.row] else {
            return nil
        }

        return movie
    }

    func isDataAvailable() -> Bool {
        guard let _ = self.movies else {
            return false
        }
        return true
    }

    func fetchData(freshLoad: Bool = false ) {
        if freshLoad {
            DataManager.sharedInstance.currentPage = 0
        }

        DataManager.sharedInstance.fetchMoviesData()
    }

    func filterFlicks(key : String) -> [Movie] {
        let movies = self.movies

        return (movies?.filter { movie in
            (movie.title?.lowercased().contains(key.lowercased()))!
            })!
    }
}

