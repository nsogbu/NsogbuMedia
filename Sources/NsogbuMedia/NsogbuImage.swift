//
//  File.swift
//  NsogbuMedia
//
//  Created by Nsogbu on 6/1/24.
//

import Foundation
import UIKit

// Public class to handle image loading operations
public class NsogbuImage {

    // Method to load an image from a URL
    public static func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Create a data task to download the image data
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure there is data and no errors
            guard let data = data, error == nil else {
                // If there's an error, call completion with nil
                completion(nil)
                return
            }
            // Create a UIImage from the downloaded data
            let image = UIImage(data: data)
            // Call the completion handler with the loaded image
            completion(image)
        }.resume() // Start the data task
    }

    // Method to load a GIF from a URL
    public static func loadGif(from url: URL, completion: @escaping ([UIImage]?, TimeInterval) -> Void) {
        // Create a data task to download the GIF data
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure there is data and no errors
            guard let data = data, error == nil else {
                // If there's an error, call completion with nil images and zero duration
                completion(nil, 0)
                return
            }
            // Parse the GIF data to get the images and duration
            let imagesAndDuration = UIImage.gifImagesAndDuration(from: data)
            // Call the completion handler with the loaded images and duration
            completion(imagesAndDuration.images, imagesAndDuration.duration)
        }.resume() // Start the data task
    }
}

extension UIImage {
    // Method to parse GIF data and get images and duration
    public static func gifImagesAndDuration(from data: Data) -> (images: [UIImage]?, duration: TimeInterval) {
        // Create a CGImageSource from the GIF data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            // Return nil and zero duration if the source creation fails
            return (nil, 0)
        }

        // Get the number of frames in the GIF
        let count = CGImageSourceGetCount(source)
        // Array to store the images
        var images = [UIImage]()
        // Variable to store the total duration of the GIF
        var duration: TimeInterval = 0

        // Iterate over each frame in the GIF
        for i in 0..<count {
            // Create a CGImage for the current frame
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                // Get the duration of the current frame
                let frameDuration = UIImage.gifFrameDuration(from: source, at: i)
                // Add the frame duration to the total duration
                duration += frameDuration
                // Create a UIImage from the CGImage and add it to the array
                images.append(UIImage(cgImage: cgImage))
            }
        }

        // Return the array of images and the total duration
        return (images, duration)
    }

    // Method to get the duration of a specific frame in a GIF
    public static func gifFrameDuration(from source: CGImageSource, at index: Int) -> TimeInterval {
        // Get the properties of the GIF frame
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
              // Get the unclamped delay time or the delay time from the properties
              let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval ?? gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval else {
            // Default frame duration if properties are missing
            return 0.1
        }
        // Return the frame duration
        return delayTime
    }
}
