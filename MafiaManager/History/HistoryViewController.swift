//
//  HistoryViewController.swift
//  MafiaManager
//
//  Created by Aishwarya Shashidhar on 3/24/19.
//  Copyright © 2019 Aishwarya Shashidhar. All rights reserved.
//
//  Dummy for now, responsible for handling the history tab view controller (stretch goal)
import UIKit
import Firebase
import MultipeerConnectivity

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var playersOfGames: [NSDictionary] = []
    private let refreshControl = UIRefreshControl()

    class GameHistory {
        var deckName : String?
        var narrator: String?
        var date:String?
        init(_date: String, _deck: String, _narrator: String) {
            date = _date
            deckName = _deck
            narrator = _narrator
        }
    }

    @IBOutlet weak var historyTableView: UITableView!
    var games: [GameHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.reloadData()
        if #available(iOS 10.0, *) {
            historyTableView.refreshControl = refreshControl
        } else {
            historyTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(retrieveGameHistory), for: .valueChanged)
        retrieveGameHistory()
    }
    
    
    @objc func retrieveGameHistory(){
        var newGames: [GameHistory] = []
        var newPlayers:  [NSDictionary] = []
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            // Check if has deck names
            if (snapshot.hasChild("games")) {
                ref.child("users").child(userID).child("games").observeSingleEvent(of: .value, with: { (snapshot1) in
                    let enumerator = snapshot1.children
                    while let rest = enumerator.nextObject() as? DataSnapshot {
                        print(rest)
                        var infoGameArr = rest.key.split(separator: "=")
                        let deckName = String(infoGameArr[0])
                        let dateTime = String(infoGameArr[1])
                        
                        let convertedFormat =  HelperFunctions.convertToString(dateString: dateTime, formatIn: "MMM dd, yyyy 'at' hh:mm:ss a", formatOut: "MM/dd/yy")
                        
                        let playerVals = rest.value as! NSDictionary
                        
                        if playerVals["players"] != nil {
                            let allPlayers = playerVals["players"] as! NSDictionary
                            newPlayers.append(allPlayers)
                            print(newPlayers)
                        } else {
                            // No game/players
                            newPlayers.append(["No players":"N/A"])
                        }
                        newGames.append(GameHistory(_date: convertedFormat, _deck: deckName, _narrator: "\(playerVals["narrator"] ?? "Narrator")"))
                        self.games = newGames
                        self.playersOfGames = newPlayers
                        self.historyTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "historyTableResultsCell", for: indexPath as IndexPath) as! HistoryTableViewCell
        let gameHistoryItem = games[indexPath.item]
        cell.dateLabel.text = gameHistoryItem.date
        cell.deckLabel.text = gameHistoryItem.deckName
        cell.narratorLabel.text = gameHistoryItem.narrator
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromHistoryViewToHistoryDetail" {
            let destinationVC = segue.destination as! HistoryGameDetailViewController
            let funcIndex = historyTableView.indexPathForSelectedRow?.row
            destinationVC.deckName = games[funcIndex!].deckName
            destinationVC.otherPlayers = playersOfGames[funcIndex!]
        }
    }
}
