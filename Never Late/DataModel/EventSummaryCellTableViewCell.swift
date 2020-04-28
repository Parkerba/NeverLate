//
//  EventSummaryCellTableViewCell.swift
//  Never Late
//
//  Created by parker amundsen on 9/18/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import UIKit

// This is a custom UITableViewCell to be used in the NeverLateEntryViewController
class EventSummaryCellTableViewCell: UITableViewCell {
    var event: Event? = nil
    var driveTimeLabel = UILabel()
    var mainTitleLabel = UILabel()
    
    var containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        containerView.layer.cornerRadius = 15
        containerView.clipsToBounds = true
        containerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
        addSubview(containerView)
        containerView.addSubview(mainTitleLabel)
        containerView.addSubview(driveTimeLabel)
        configureLabels()
    }
    
    func configureLabels() {
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        mainTitleLabel.layer.cornerRadius = 10
        mainTitleLabel.numberOfLines = 4
        mainTitleLabel.adjustsFontSizeToFitWidth = true
        
        driveTimeLabel.layer.cornerRadius = 20
        driveTimeLabel.clipsToBounds = true
        driveTimeLabel.backgroundColor = .green
        driveTimeLabel.textAlignment = .center
        driveTimeLabel.numberOfLines = 0
        
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTitleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        mainTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        mainTitleLabel.trailingAnchor.constraint(equalTo: driveTimeLabel.leadingAnchor, constant: -10).isActive = true
        
        driveTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        driveTimeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        driveTimeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        driveTimeLabel.widthAnchor.constraint(equalToConstant: self.frame.width/4).isActive = true
        driveTimeLabel.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
    }
    
    func set(passedEvent: Event) {
        self.layer.cornerRadius = 15
        self.event = passedEvent
        let eventTitle : String = "\(event!.title)\n"
        let eventLocationName : String = (event!.locationName == nil) ? "" : "\(event!.locationName!)\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, @ h:mm a"
        let formattedDateString = formatter.string(from: event!.eventDate)
        mainTitleLabel.text = "\(eventTitle)\(eventLocationName)\(formattedDateString)"
        mainTitleLabel.font = UIFont(name: "Arial", size: 20)
        if (event?.driveTime) != nil {
            setDriveTimeLabel()
        } else {
            self.driveTimeLabel.isHidden = true
        }
    }
    
    private func setDriveTimeLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = .autoupdatingCurrent
        let timeToLeave: String = formatter.string(from: event!.departureTime!)
        let timeUntilDeparture: Double = Double((event!.departureTime!.timeIntervalSinceNow))
        if (timeUntilDeparture < 0) {
            driveTimeLabel.backgroundColor = .red
        } else if (timeUntilDeparture < 600) {
            driveTimeLabel.backgroundColor = .yellow
        } else {
            driveTimeLabel.backgroundColor = .green
        }
        driveTimeLabel.text = "\(event!.driveTime!/60) min\n\(timeToLeave)"
        self.driveTimeLabel.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
