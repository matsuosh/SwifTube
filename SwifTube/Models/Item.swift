//
//  Item.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/17.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Alamofire


extension SwifTube {

    static func dateFromPublisehdAt(publishedAt: String) -> NSDate {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.dateFromString(publishedAt)!
    }

    static func formatFromDuration(duration: String) -> String {
        let scanner = NSScanner(string: duration)
        scanner.charactersToBeSkipped = NSCharacterSet.letterCharacterSet()
        var scanned = [Int]()
        while !scanner.atEnd {
            var int: Int32 = 0
            scanner.scanInt(&int)
            scanned.append(Int(int))
        }
        switch scanned.count {
        case 3:
            return NSString(format: "%d:%02d:%02d", scanned[0], scanned[1], scanned[2])
        case 2:
            return NSString(format: "%d:%02d", scanned[0], scanned[1])
        case 1:
            return NSString(format: "0:%02d", scanned[0])
        default:
            return "00:00"
        }
    }

    class Item {

        let id: String
        let publishedAt: NSDate?
        let title: String
        let description: String
        let thumbnailURL: String!
        
        required init(item: NSDictionary) {
            let snippet = item["snippet"] as NSDictionary
            let thumbnails = snippet["thumbnails"] as NSDictionary
            
            self.id = item["id"] as String
            self.title = snippet["title"] as String
            self.description = snippet["description"] as String
            if let publishedAt = snippet["publishedat"] as? String {
                self.publishedAt = SwifTube.dateFromPublisehdAt(publishedAt)
            }
            for quality in ["standard", "high", "medium", "default"] {
                if let thumbnail = thumbnails.valueForKey(quality) as? NSDictionary {
                    self.thumbnailURL = thumbnail["url"] as String
                    break
                }
            }
        }
        
        func thumbnailImage(completion: (image: UIImage!, error: NSError!) -> Void) {
            Alamofire.request(.GET, thumbnailURL).response { (_, _, data, error) in
                if let image = UIImage(data: NSData(data: data as NSData)) {
                    completion(image: image, error: nil)
                } else {
                    completion(image: nil, error: error)
                }
            }
        }
        
    }
    
    class Video: Item {
        
        let channelTitle: String
        let viewCount: Int
        let duration: String
        
        enum Quality: Int {
            case Low = 36
            case Medium = 18
            case High = 22
            case FullHigh = 37
        }
        
        required init(item: NSDictionary) {
            let snippet = item["snippet"] as NSDictionary
            let contentDetails = item["contentDetails"] as NSDictionary
            let statistics = item["statistics"] as NSDictionary
            
            self.channelTitle = snippet["channelTitle"] as String
            //self.duration = contentDetails["duration"] as String
            self.duration = SwifTube.formatFromDuration(contentDetails["duration"] as String)
            self.viewCount = (statistics["viewCount"] as String).toInt()!
            
            super.init(item: item)
        }

        func streamURL(quality: Quality = Quality.High, completion: (streamURL: NSURL!, error: NSError!) -> Void) {
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(id) { (video: XCDYouTubeVideo!, error: NSError!) in
                if video != nil {
                    for quality in [Quality.FullHigh, Quality.High, Quality.Medium, Quality.Low] {
                        if let streamURL = video.streamURLs[quality.rawValue] as? NSURL {
                            completion(streamURL: streamURL, error: nil)
                            return
                        }
                    }
                } else {
                    completion(streamURL: nil, error: error)
                }
            }
        }
        
    }
    
    class Playlist: Item {
        
        let channelTitle: String
        let itemCount: Int?
        
        required init(item: NSDictionary) {
            let snippet = item["snippet"] as NSDictionary
            let contentDetails = item["contentDetails"] as NSDictionary
            
            self.channelTitle = snippet["channelTitle"] as String
            if let itemCount = contentDetails["itemCount"] as? Int {
                self.itemCount = itemCount
            }
            super.init(item: item)
        }
        
//        func videos(completion: (videos: [Video]!, token: PageToken!, error: NSError!) -> Void) {
//            SwifTube.playlistItems(id: id) { (videos: [Video]!, token: PageToken!, error: NSError!) in
//                if let videos = videos {
//                    completion(videos: videos, token: token, error: error)
//                } else {
//                    completion(videos: nil, token: nil, error: error)
//                }
//            }
//        }
        
    }
    
    class Channel: Item {
        
        let viewCount: Int?
        let subscriberCount: Int?
        let videoCount: Int?
        
        required init(item: NSDictionary) {
            let statistics = item["statistics"] as NSDictionary
            if let viewCount = statistics["viewCount"] as? String {
                self.viewCount = viewCount.toInt()
            }
            if let subscriberCount = statistics["subscriberCount"] as? String {
                self.subscriberCount = subscriberCount.toInt()
            }
            if let videoCount = statistics["videoCount"] as? String {
                self.videoCount = videoCount.toInt()
            }
            super.init(item: item)
        }

//        func videos(completion: (videos: [Video]!, error: NSError!) -> Void) {
//            SwifTube.search(parameters: ["channelId": id]) { (videos: [Video]!, token: PageToken!, error: NSError!) in
//                if let videos = videos {
//                    completion(videos: videos, error: error)
//                } else {
//                    completion(videos: nil, error: error)
//                }
//            }
//        }
        
//        func playlists(completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
//            SwifTube.search(parameters: ["channelId": id]) { (playlists: [Playlist]!, token: PageToken!, error: NSError!) in
//                if let playlists = playlists {
//                    completion(playlists: playlists, error: error)
//                } else {
//                    completion(playlists: nil, error: error)
//                }
//            }
//        }
        
    }
    
}

protocol Serializable {
    init(item: NSDictionary)
}

protocol APICaller: Serializable {
    class func callAPI(ids: [String]) -> SwifTube.API
}

extension SwifTube.Video: APICaller {
    class func callAPI(ids: [String]) -> SwifTube.API {
        return SwifTube.API.Videos(ids: ids)
    }
}

extension SwifTube.Playlist: APICaller {
    class func callAPI(ids: [String]) -> SwifTube.API {
        return SwifTube.API.Playlists(ids: ids)
    }
}
extension SwifTube.Channel: APICaller {
    class func callAPI(ids: [String]) -> SwifTube.API {
        return SwifTube.API.Channels(ids: ids)
    }
}