# Social App with Flutter

This is a Flutter application that clones a social app similar to Twitter, based on a YouTube tutorial by Mitch Koko. The app's structure, module organization, and logic have been modified and enhanced. It follows the principles of Clean Architecture, ensuring a well-organized and maintainable codebase. The app also uses Provider as the state management solution.

## Firebase Setup
- Create new project in firebase
- Setup app for Android (google-services.json) and iOS (GoogleService-Info.plist), more info visit [here](https://firebase.google.com/docs/flutter/setup)
- Enable authentication 
- Enable firestore database
- set rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
       allow read: if true;
       allow write: if request.auth != null;
    }
  }
}
```

## Screenshoots
<table>
  <tr>
    <th>Login</th>
    <th>Register</th>
    <th>Home</th>
        <th>Post</th>
  </tr>
  <tr>
    <td><img src="screenshoot/1.%20login.png" height="25%"/></td>
    <td><img src="screenshoot/2.%20register.png" height="25%"/></td>
    <td><img src="screenshoot/3.%20home.png" height="25%"/></td>
    <td><img src="screenshoot/4.%20post.png" height="25%"/></td>
  </tr>
</table>

<table>
  <tr>
    <th>Drawer</th>
    <th>Profile</th>
    <th>Update Bio</th>
        <th>Follow </th>
  </tr>
  <tr>
    <td><img src="screenshoot/5.%20drawer.png" height="25%"/></td>
    <td><img src="screenshoot/6.%20profile.png" height="25%"/></td>
    <td><img src="screenshoot/7.%20update%20bio.png" height="25%"/></td>
    <td><img src="screenshoot/8.%20follow.png" height="25%"/></td>
  </tr>
</table>

  <table>
  <tr>
    <th>Follow post</th>
    <th>Follow user list</th>
    <th>Search username</th>
        <th>Settings</th>
  </tr>
  <tr>
    <td><img src="screenshoot/9.%20follow%20post.png" height="25%"/></td>
    <td><img src="screenshoot/10.%20follow%20user%20list.png" height="25%"/></td>
    <td><img src="screenshoot/11.%20search%20username.png" height="25%"/></td>
    <td><img src="screenshoot/12.%20settings.png" height="25%"/></td>
  </tr>
</table>

  <table>
  <tr>
    <th>Blocked user</th>
    <th>Delete account</th>
    <th>Light mode</th>
  </tr>
  <tr>
    <td><img src="screenshoot/13.%20blocked%20user.png" height="25%"/></td>
    <td><img src="screenshoot/14.%20delete%20account.png" height="25%"/></td>
    <td><img src="screenshoot/15.%20light%20mode.png" height="25%"/></td>
  </tr>
</table>

## Credits
- [Mitch Koko](https://www.youtube.com/@createdbykoko)
