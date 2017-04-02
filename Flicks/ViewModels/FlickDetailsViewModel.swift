//
//  FlickDetailsViewModel.swift
//  Flicks
//
//  Created by Pattanashetty, Sadananda on 4/1/17.
//  Copyright © 2017 Pattanashetty, Sadananda. All rights reserved.
//

import Foundation

class FlickDetailsViewModel {

    var movie: Movie

     init(movie: Movie) {
        self.movie = movie
    }

    func posterUrl() -> URL? {
        let baseUrl = "http://image.tmdb.org/t/p/w342"

        if let path = movie.poster_path  {
            return URL(string: baseUrl + path)
        }

        return nil
    }
}
