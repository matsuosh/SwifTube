//
//  PlaylistsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class PlaylistsViewController: ItemsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPlaylist" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as PlaylistViewController
                destinationViewController.playlist = items[indexPath.row] as SwifTube.Playlist
            }
        }
    }
    
    override func search() {
        SwifTube.search(parameters: searchParameters, completion: { (playlists: [SwifTube.Playlist]!, token: SwifTube.PageToken!, error: NSError!) in
            if let playlists = playlists {
                self.updateSearchParameters(token: token)
                self.items = playlists
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        })
    }

}

extension PlaylistsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            var cell  = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell", forIndexPath: indexPath) as PlaylistTableViewCell
            let item = items[indexPath.row] as SwifTube.Playlist
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as LoadMoreTableViewCell
            cell.button.addTarget(self, action: "populateItems", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }
    
    override func populateItems() {
        SwifTube.search(parameters: searchParameters) { (playlists: [SwifTube.Playlist]!, token: SwifTube.PageToken!, error: NSError!) in
            if let playlists = playlists {
                self.updateSearchParameters(token: token)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let lastIndex = self.items.count
                    for playlist in playlists {
                        self.items.append(playlist)
                    }
                    let indexPaths = (lastIndex ..< self.items.count).map { (transform: Int) -> NSIndexPath in
                        return NSIndexPath(forItem: transform, inSection: 0)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                }
            }
        }
    }
}

extension PlaylistsViewController: UITableViewDelegate {
}