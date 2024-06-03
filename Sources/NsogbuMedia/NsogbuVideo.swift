//
//  NsogbuVideo.swift
//
//
//  Created by Nsogbu on 6/3/24.
//

import UIKit
import AVKit

// Custom table view cell to display a video using AVPlayerViewController
public class NsogbuVideo {
    
    public static func loadVideo(url: URL, completion: @escaping (AVPlayerViewController) -> Void) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        completion(playerViewController)
    }
}
