## **PhotoFlow** 
PhotoFlow - the multi-page application is designed for viewing images through the Unsplash API.

## **Links**
[Design Figma](https://www.figma.com/file/HyDfKh5UVPOhPZIhBqIm3q/Image-Feed-(YP)?type=design&node-id=318-1469&mode=design&t=87ihA4MlRvrOVm3j-0)  

[Unsplash API](https://unsplash.com/documentation)

## **Application description and purpose**
This application with multiple pages is created for the purpose of viewing images using the Unsplash API.

- Browse an infinite flow of pictures from Unsplash Editorial;
- View brief information from the user's profile;

  
  ## **Purpose**
- In the application, authorization via OAuth Unsplash is required;
- The main screen consists flow of images. Users can browse it;
- Users can view each image individually and share a link to them outside the application;
- Users have a profile with favorite images and brief user information;
- Additionally, there is a favorite feature and the ability to like photos while viewing images in full screen.

## **Technical requirements**
- Authentication is done through OAuth Unsplash and a POST request to obtain an Auth Token.
- The feed is implemented using UITableView.
- The application utilizes UImageView, UIButton, UILabel, TabBarController, NavigationController, NavigationBar, UITableView, and UITableViewCell.
- The application must support iPhones with **iOS 13** or higher, and only portrait mode is supported.


## **Functional Requirements**
 **OAuth Authentication**
 - Users must authenticate through OAuth to access the app.
 - The authorization screen includes the app's logo and a "Login" button.
   User actions:
- Upon app launch, the user sees a splash screen.
- After the app loads, the authentication screen opens.
- Clicking the "Login" button opens a browser on the Unsplash authorization page.
- Clicking "Login" in the browser closes it, and a loading screen appears in the app.
- If OAuth Unsplash authorization is not set up, clicking the login button has no effect.
- If OAuth Unsplash authorization is set up incorrectly, the user can't log in, and an error modal appears.
- Unsuccessful login attempts trigger a modal window with an error.
- Clicking "OK" returns the user to the login screen.
- Upon successful authorization, the browser closes, and the feed screen opens.

  ## **Viewing the Feed**
  - Users can view images in the feed, view individual images, and add them to favorites.
  - The feed screen includes an image card, a "Like" button, and the photo upload date.
User actions:
- The feed screen opens by default after logging into the app.
- The feed includes images from Unsplash Editorial.
- Scrolling up and down allows users to browse the feed.
- A system loader appears if an image hasn't loaded.
- A placeholder is shown if an image cannot load.
- Clicking the "Like" button allows users to like an image, displaying a loader. Successful requests change the icon to a red heart, while unsuccessful ones trigger an error modal.
- Users can remove a like by clicking the red heart icon, displaying a loader. Successful requests change the icon back to a gray heart, while unsuccessful ones trigger an error modal.
- Clicking an image card enlarges it to fill the screen, and users can navigate to the full-screen view.

  ## **Viewing Images in Full-Screen Mode**

- Users can view images in full-screen mode and share them.
- The full-screen view includes an enlarged image, a back button, and a download and share button.
- User actions:
- The full-screen view displays a stretched image that's centered.
- If an image can't load, a placeholder is shown.
- If a request fails, a system alert appears.
- Users can navigate by swiping, zooming, and rotating the stretched image.
- If gesture actions are not configured for zoom or rotation, those actions are not available.
- Clicking the "Share" button opens a system menu for downloading or sharing the image. The menu disappears after an action is performed.
- Users can close the menu by swiping down or clicking the close button.
- If no action is configured for the "Download or Share Image" button, it won't appear.

 ## **Viewing User Profiles**

- Users can view their profiles, check profile data, or log out.
- The profile screen displays user data, a user photo, name, username, self-information, a logout button, and a tab bar.
- User actions:
- Profile data is loaded from the Unsplash profile and can't be edited within the app.
- If profile data fails to load, a placeholder is shown.
- Clicking the logout button allows users to log out. A system alert confirms the action.
- Confirming "Yes" logs the user out and returns them to the login screen. Incorrectly configured actions or failing to confirm the logout don't log out the user.
- Selecting "No" returns the user to the profile screen.
- If the alert is not configured, clicking the logout button has no effect.
- Users can switch between the feed and profile screens using the tab bar.
