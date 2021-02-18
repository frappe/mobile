
# Frappe Mobile

Mobile Version of Frappe built on Flutter.

**Please Note, this Project is still in beta stage and requires latest version of frappe framework v13**

<kbd><img width="216" height="432" src="screenshots/login.png" alt="Frappe Books Preview" /></kbd>
<kbd><img width="216" height="432" src="screenshots/home.png" alt="Frappe Books Preview" /></kbd>
<kbd><img width="216" height="432" src="screenshots/list_view.png" alt="Frappe Books Preview" /></kbd>

## Features:
1) Offline First (Data is automatically fetched in background every 30 mins)
3) Create/Update Docs (queued when offline and processed automatically when reconnected to internet)
4) Add/Remove Assignees, Tags
5) Add/Remove/Download Attachments 
6) Add Comments, Send Email
7) Appreciate/Criticize Users involved in specified Doc.
8) Timeline
9) Awesombar


## Development

0) To run this Project first you need to [Setup Flutter](https://flutter.dev/docs/get-started/install)

1) Install packages<br/>
```sh
pub packages get
```
2) Run the Project<br/>
```sh
flutter run
```

### Architecture

This Project roughly follows MVVM Architecture where each screen has seperate file and each stateful screen is contained in a folder with 2 files 

1) View file (layout logic) 
2) View Model File (data processing and state management). 

This Project uses [provider](https://pub.dev/packages/provider) for State Management. 
[hive](https://pub.dev/packages/hive), [shared_preferences](https://pub.dev/packages/shared_preferences) for storage. 
[dio](https://pub.dev/packages/dio) for making network requests.
