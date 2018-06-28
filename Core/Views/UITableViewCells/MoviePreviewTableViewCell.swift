//
//  MoviePreviewTableViewCell.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit
import ImagineDragon

class MoviePreviewTableViewCell: UITableViewCell {
    class Model {
        var imageContainer: ImagineDragon.ImageContainer?
        var title: String?
        var date: String?
    }
    var model: Model?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var posterImageView: UIImageView?
}

// cleanup
extension MoviePreviewTableViewCell {
    override func prepareForReuse() {
        self.model?.imageContainer?.cancel()
        self.model?.imageContainer = nil
        self.posterImageView?.image = nil
    }
}

// MARK: HasModelProtocol
extension MoviePreviewTableViewCell: HasModelProtocol {
    typealias ModelType = Model
    func updateForNewModel() {
        // do something?
        self.titleLabel.text = self.model?.title
        self.dateLabel.text = self.model?.date        
        self.model?.imageContainer = ImagineDragon.ImageContainer()
        self.model?.imageContainer?.imageViewAccessor = self
    }
}

// MARK: HasImageView
extension MoviePreviewTableViewCell: ImagineDragon.HasImageView {
    func imageViewAccessor() -> UIImageView? {
        return self.posterImageView
    }
}

// MARK: Configuration
extension MoviePreviewTableViewCell.Model {
//    private func configured(hasImageView: HasImageView?) -> Self {
//        self.imageContainer?.imageViewAccessor = hasImageView
//        return self
//    }
    func configured(mediaManager: MediaManager?) -> Self {
        self.imageContainer?.mediaManager = mediaManager
        return self
    }
    
    func configured(movie: Movie?) -> Self {
        self.title = movie?.title
        self.date = movie?.year
        return self
    }
    
    func configured(url: URL?) -> Self {
        self.imageContainer?.setUrl(url: url)
        return self
    }
}
