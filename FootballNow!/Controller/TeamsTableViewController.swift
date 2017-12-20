//
//  TeamsTableViewController.swift
//  FootballNow!
//
//  Created by Fredrick Ohen on 12/4/17.
//  Copyright © 2017 geeoku. All rights reserved.
//

import UIKit

class TeamsTableViewController: UITableViewController {
  
  var teams: [Team] = []
  var leagues = ["PL", "La Liga", "Ligue 1"]

    override func viewDidLoad() {
        super.viewDidLoad()
      registerNibFiles()
      retrieveTeamsFromApi()
      createSegmentedControl()

    }
  
  func createSegmentedControl() {
    let leaguesSegmentedControl = UISegmentedControl(items: leagues)
    leaguesSegmentedControl.selectedSegmentIndex = 0
    leaguesSegmentedControl.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
    self.tableView.tableHeaderView = leaguesSegmentedControl

  }

  func registerNibFiles() {
    tableView.register(UINib(nibName: "TeamsTableViewCell", bundle: nil), forCellReuseIdentifier: "TeamsCell")
  }
  
  
  func retrieveTeamsFromApi() {
    let teamsURL = "http://api.football-data.org/v1/competitions/445/teams"
    guard let url = URL(string: teamsURL) else { return }
    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, response, error) in
      if let error = error {
        DispatchQueue.main.async {
          //make UI error Change
          print(error.localizedDescription)
        }
        return
      }
      
      guard let data = data else { return }
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        DispatchQueue.main.async {
          // Make UI error Change
        }
        return
      }
      
      let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      guard let jsonTeams = json["teams"] as? [[String:Any]] else { return }
      for team in jsonTeams  {
         do {
           let team = try Team(json: team)
            self.teams.append(team)
        } catch let error {
          print(error.localizedDescription)
        }
      }
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
      task.resume()
  }
  
  // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamsCell", for: indexPath) as! TeamsTableViewCell
      
      cell.layer.cornerRadius = cell.layer.frame.height / 2
      //cell.selectionStyle = .none
      
      cell.nameLabel.text = teams[indexPath.row].name
      cell.codeLabel.text = teams[indexPath.row].code
      cell.shortNameLabel.text = teams[indexPath.row].shortName
    
      
        let crestUrls = self.teams[indexPath.row].crestUrl
        let crestWebView = cell.crestWebView
        
        
        let crestURL = URL(string: crestUrls)
        let request = URLRequest(url: crestURL!)
        crestWebView?.load(request)
     

      return cell
    }
  
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 292
    }

}
