# NeverLateGit

Gifs to come soon!

NOTE: to run this app you need a valid google distance matrix api key! 

The key should be inserted as a String that is being assigned to the variable titled "apiKey" in the getDriveTimeInfo method in the GoogleRequest class!

--------About NeverLate---------

- NeverLate is an app to prevent you from being late!
- Create an event by tapping the gray button in the entry view controller (first screen).
- The event can be assigned a title, description, desired arrival time, starting location (or just use current location), and destination location.
- After all the desired information is included its time to save the event using the gold "Done" button.
- On clicking the "Done" button the following happens:


- - The event information is saved locally using the Codable protocol and the device's filesystem.
- - Requests to Googles distance matrix API are made.
- - JSON data containing drive time predictions is retrieved and parsed.
- - A local notification containing the event information and options to open in maps are scheduled to be delivered when you need to leave to arrive at the specified event arrival time.

- The new event is displayed to the user in the entry view controllers table view (list).
- Each Cell in the first ViewController's (Screen's) UITableView represents a scheduled event.
- You can interact with each cell in the following ways:
- - swipe right to open the location in apple maps
- - swipe left to delete the event and cancel the scheduled notification
- - tap to present a detail view where you can edit the event information!

Finally: This application is a work in progress, feel free to leave me constructive feedback at parkera13@gmail.com thanks!
