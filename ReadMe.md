# Buro project overview
Buro is a custom “PowerApp” that was developed using Microsoft’s Power Platform. Buro is intended to help ISED employees return to work by allowing them to reserve a seat prior to coming into the office. The app will reside in Microsoft Teams. Buro will be available both for desktop and mobile device users. Anyone with a network account will be able to access the application from the ISED intranet and sign-in with their windows (AD) credentials through IdM.

# Technical overiew
Buro is a custom PowerApp that any ISED user with a network account will be able to access through Microsoft Teams with HTTPS connection over ISED’s intranet. Users must be on the ISED network to access the application.Buro DEV, UAT, and PROD environments will reside on the ISED Power Platform instance. DEV and UAT are unclassified while PROD will store information in a SharePoint list(s) that hosts content which is not considered Protected A or B. 
Buro is a cloud based PowerApp that resides within an environment provided by Microsoft. The environment is created within an Azure AD tenant. PowerApps and the Power Platform can be considered as an instance of PASS (platform as a service). Data within a PowerApps resides and is obtained from the organization’s office 365 account. Buro currently leverages the office 365 connector to obtain user information. The backend of Buro contains connectors provided by PowerApps, SharePoint lists, and some additional customization. Many of the components are hidden from the developer as it is a cloud service provided by Microsoft. PowerApps has its own custom language intended for development. Buro makes no use of any external or custom APIs currently. 

# Getting started
Once a stable version of Buro is ready to be added to the repository the following steps are executed in order to extract source files and update the repository.

For further information on the PowerApps Language Tooling read the documentation [found here](https://github.com/microsoft/PowerApps-Language-Tooling#readme). This is an experimental tool created by Microsoft to support source control for apps created in PowerApps.

## Required dependencies:
- [Git](https://desktop.github.com/) (Desktop or CLI version)
- [.NET Core 3.1.x (x64)](https://dotnet.microsoft.com/download/dotnet-core/3.1)
- [Visual Studio](https://visualstudio.microsoft.com/downloads/)
- [Power Platform Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.powerplatform-vscode)

## Setting up dependencies:
1. Install Git
2. Install .NET Core 3.1.x
3. Install Visual Studio
4. Open Visual Studio and open the "Extensions"
    
    a) Search for "Power Platform Tools"

    b) Install the extension 

## Steps to extract source files from a PowerApp:

1. Navigate to the [PowerApps wesbite](https://make.powerapps.com) and click on the Apps section
2. On the app you'd like to integrate source control into, click the "..." three ellipses and click "Edit"
3. Once the app has loaded in PowerApps Studio, click **File > Save As > This computer > Download**

    _Note: This will download the app and put it into a "*.msapp" file_

4. Navigate to the location that the .msapp file was downloaded to
5. Open Visual Studio
6. Open the Visual Studio Terminal
7. Change the directory of the terminal to where the .msapp file is (ex. D:\Users\Name\Downloads)
8. In the terminal:

    a) The extraction/unpacking command should follow this convention: 
    
    ```pac canvas unpack --msapp FromApp.msapp --sources ToSourceFolder```

    *Note: 'FromApp.msapp' is the name of the .msapp file you downloaded from PowerApps. 'ToSourceFolder' is the path to the folder where the .msapp file is will be extracted to (ie. D:\Users\Name\Downloads\ToSourceFolder)*

    b) Press Enter

8. If the process successfully extracted your app's source files they should now appear in the output folder you specified

9. These source files can now be added to your repository


## Steps to import source files into a PowerApp:

In order to use the source files from our repository on the [PowerApps wesbite](https://make.powerapps.com) we must convert our source files to a .msapp file. This is essentially the reverse process that we followed in the [previous section](#powerapps-source-file-extraction-flow) 

1. Open Visual Studio
2. Open the Visual Studio Terminal
3. Locate the directory on your computer that you have the Buro source files cloned from this repository

4. In the terminal, from step 2, we'll construct the bundling command

    a) The bundling/packing command should follow this convention: 
    
    ```pac canvas pack --msapp ToApp.msapp --sources FromSourceFolder```

    *Note: 'ToApp.msapp' is the name you'd like to call the app followed by the .msapp file extension. 'FromSourceFolder' is the path to the folder where the the source files of the Buro application are located*

    b) Press Enter

5. If the process successfully bundled your app's source files the .msapp file with the name you specified should now appear in the current directory the terminal is in

6. Go to [PowerApps Studio](https://us.create.powerapps.com/studio/)

7. Click on **File > Open > Browse** and select the .msapp file we packaged

# Major features

* Booking a room for yourself 
* Booking a room for someone else
* Viewing past, present, and future bookings made for yourself, for another person, or by another person
* User Profile - contains useful user information and settings
* Feedback - allows for continuous improvement 


# Language and accessibility 

Buro supports both English and French. Accessibility testing and usability tests where conducted before the deployment of the applicaton. 

# Data storage and security 

Data is stored using sharepoint lists. This includes booking data and room information. 

# SharePoint tables and necessary table structures

## Users table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|user_email|Yes|
|Choice|language|Yes|
|Number|reservations_made|Yes|
|Yes/No|tester|Yes|

## Regions table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|region_name_en|Yes|
|Single line of text|region_name_fr|Yes|

## Desks table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|desk_name_en|Yes|
|Single line of text|desk_name_fr|Yes|
|Choice|status|Yes|
|Lookup|building_id|Yes|
|Lookup|neighbourhood_id|Yes|
|Lookup|seating_type_id|Yes|
|Lookup|seating_arrangement_id|Yes|
|Choice|workstation_specifics|Yes|
|Hyperlink or Picture|desk_floor_plan_url|Yes|
|Hyperlink or Picture|desk_image|Yes|

## Buildings table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|building_add_en|Yes|
|Single line of text|building_add_fr|Yes|
|Single line of text|building_name_en|Yes|
|Single line of text|building_name_fr|Yes|
|Single line of text|building_name_en|Yes|
|Single line of text|city|Yes|
|Single line of text|province|Yes|
|Single line of text|postal_code|Yes|
|Lookup|region_id|Yes|

## Floors table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|floor_name_en|Yes|
|Single line of text|floor_name_fr|Yes|
|Lookup|building_id|Yes|

## Neighbourhoods table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|neighbourhood_name_en|Yes|
|Single line of text|neighbourhood_name_fr|Yes|
|Lookup|floor_id|Yes|

## Neighbourhoods table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|desk_name_en|Yes|
|Single line of text|desk_name_fr|Yes|
|Choice|status|Yes|
|Lookup|building_id|Yes|
|Lookup|neighbourhood_id|Yes|
|Lookup|seating_type_id|Yes|
|Lookup|seating_arrangement_id|Yes|
|Hyperlink or Picture|desk_floor_plan_url|Yes|
|Hyperlink or Picture|desk_image|Yes|
|Choice|additional_info|No|

## SeatingArrangements table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|seating_arrangement_name_en|Yes|
|Single line of text|seating_arrangement_name_fr|Yes|
|Hyperlink or Picture|icon_link|Yes|

## SeatingTypes table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|seating_type_name_en|Yes|
|Single line of text|seating_type_name_fr|Yes|
|Single line of text|seating_type_description_en|Yes|
|Single line of text|seating_type_description_fr|Yes|
|Hyperlink or Picture|seating_type_image|Yes|

## Timeslots table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|time_range_en|Yes|
|Single line of text|time_range_fr|Yes|
|Single line of text|start_time|Yes|
|Single line of text|end_time|Yes|
|Number|start_time_in_min|Yes|
|Number|end_time_in_min|Yes|

## Reservations table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|user_email|No|
|Single line of text|proxy_user_email|No|
|Lookup|desk_id|Yes|
|Date|start_date|Yes|
|Lookup|timeslot_id|Yes|
|Choice|status|Yes|

## ExternalErrors table

|Type|Column|Required|
|---|---|:---:|
|Single line of text|user_email|Yes|
|Number|error_code|No|
|Multiple lines of text|error_log|No|
|Single line of text|error_origin|No|
|Multiple lines of text|error_message|No|

## Translations table

|Type|Column|Required|
|---|---|:---:|
|Multiple lines of text|key|Yes|
|Multiple lines of text|text|Yes|
|Choice|language|Yes|


# Error handling

In Buro we leverage the use of PowerApp's experimental feature of [Errors](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/functions/function-iferror). When making requests to our database (SharePoint) we execute them under [IfError](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/functions/function-iferror#iferror) functions. When an error is found we display a full-page error modal that instructs users to restart the app, and we attempt to log this error to our database.

# Custom components
## Main navigation

- **Purpose**: A navigation bar to allow for quick access to the most functionally-important pages of the application.

- **Component name**: cmp_MainNav
    
- **Arguments**:

    ### Input

    ---

    `NavItems`

    - Purpose: A table of the items that will appear on the navigation bar. 
    - Type:  [Table]
    - Expected Format:
        
        ```
            Table(
                {
                    Key: [Text],
                    Label: [Text],
                    NavigationLink: [Screen]
                },
                ...
            )
        ```
        
    `SelectedItem`

    - Purpose: The key of the item that is selected on the navigation bar.
    - Type:  [Text]
    - Expected Value: The "Key" of one of the records in the NavItems table.

    `PrimaryColor`

    - Purpose: Color used for the selected item.
    - Type:  [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)
    
    `BackgroundColor`

    - Purpose: Color used for the navigation background.  
    - Type: [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    `MutedColor`

    - Purpose: Color used for the non-selected items on the navigation bar.  
    - Type: [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    `FocusedColor`

    - Purpose: Color used for focused elements.
    - Type:  [Color]- 
    - Expected Value:* An RGBA Value ex. RGBA(0,0,0,1)

    `NavigateToText`

    - Purpose: The accessiblity label that is read aloud when a navigation item is focused.
    - Type:  [Text]

    `FontSize`

    - Purpose: The font size of the items on the navigation bar.
    - Type:  [Number]

    `ScreenSize_Width`

    - Purpose: The numerical value of the screen's width in pixels in relation to the app's defined breakpoints.
    - Type:  [Number]

    `ScreenSize_Height`

    - Purpose: The numerical value of the screen's height in pixels in relation to the app's defined breakpoints. 
    - Type:  [Number]

    `DisableTabIndex`

    - Purpose: Whether the navigation bar can be tabbed to or not. 
    - Type:  [Boolean]

    ### Output

    ---

    n/a


 ## Page header

- **Purpose**: To provide user's with a way to navigate back to a previous page and to display the name of the current page .

- **Component name**: cmp_PageHeading
    
- **Arguments**:

    ### Input

    ---

    `HasBackBtn`

    - Purpose: Whether to show/hide the back button
    - Type:  [Boolean]

    `BackText`

    - Purpose: The accessiblity label that is read aloud when the back button is focused. 
    - Type:  [Text]
        
    `HeadingText`

    - Purpose: The name of the current page to be displayed on the header.
    - Type:  [Text]

    `PrimaryColor`

    - Purpose: Color used for the text of the header.
    - Type:  [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)
    
    `BackgroundColor`

    - Purpose: Color used for the header background.  
    - Type: [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    `SecondaryColor`

    - Purpose: Color used for the back buttons background.  
    - Type: [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    `FocusedColor`

    - Purpose: Color used for focused elements.
    - Type:  [Color]- 
    - Expected Value:* An RGBA Value ex. RGBA(0,0,0,1)

    `FontSize`

    - Purpose: The font size of the HeadingText.
    - Type:  [Number]

    `PositionOffset`

    - Purpose: The amount of left padding for the back button 
    - Type:  [Number]

    `ScreenSize_Width`

    - Purpose: The numerical value of the screen's width in pixels in relation to the app's defined breakpoints.
    - Type:  [Number]

    `ScreenSize_Height`

    - Purpose: The numerical value of the screen's height in pixels in relation to the app's defined breakpoints. 
    - Type:  [Number]
    
    `BackNavigateTo`

    - Purpose: The screen to navigate backwards to. By default if this table is empty the PowerApps Back function is invoked.
    - Type:  [Table]
    - Expected Format:

        ```
            Table(
                { 
                Key: [Text], 
                NavigationLink: [Screen]
                }
            )
        ```

    ### Output

    ---
    
    n/a

## Loading animation

- **Purpose**: To provide user's using a screen reader with the auditory cue of when a page is loading.

- **Component name**: cmp_LoadingAnimation
    
- **Arguments**:

    ### Input

    ---

    `IsTextVisible`

    - Purpose: Whether to show/hide the LoadingText provided to this component
    - Type:  [Boolean]

    `LoadingText`

    - Purpose: Text used by the component to display under the loading animation
    - Type:  [Text]

    `PrimaryColor`

    - Purpose: Color used for the LoadingText.
    - Type:  [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    ### Output

    ---
    
    n/a

## Done loading animation

- **Purpose**: To provide user's using a screen reader with the auditory cue of when a page is done loading.

- **Component name**: cmp_LoadingDoneAnimation
    
- **Arguments**:

    ### Input

    ---

    `IsTextVisible`

    - Purpose: Whether to show/hide the DoneLoadingText provided to this component
    - Type:  [Boolean]

    `DoneLoadingText`

    - Purpose: Text used by the component to display under the done loading animation
    - Type:  [Text]

    `PrimaryColor`

    - Purpose: Color used for the DoneLoadingText.
    - Type:  [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    ### Output

    ---
    
    n/a

## App screen height

- **Purpose**: To provide the developer(s) with a tool to have access to the changing height of the application in terms of breakpoints. Much like the Parent.Size function, but with respect to height instead of width. PowerApp's already provides developers with tools to make the app responsive in width. This component was developed to make the app responsive in terms of height. The ScreenSize output argument is what we will use across our applications pages to detect any screen size changes and enable the app to be used seamlessly from Desktop to Mobile layouts.

- **Component name**: cmp_ScreenFunctions
    
- **Arguments**:

    ### Input

    ---

    `AppHeight`

    - Purpose: Used to calculate the height of the application in terms of break points.
    - Type:  [Number]

    `AppHeightBreakPoints`

    - Purpose: To divide the application's height into different pixel regions based off of the Small, Medium, and Large key  values.
    - Type:  [Record]
    - Expected Format:

        ``` 
            {
                Small: [Number], 
                Medium: [Number], 
                Large: [Number]
            }
        ```

    ### Output

    ---
    
    `ScreenSize`

    - Purpose: Based on the AppHeight and AppHeightBreakPoints arguments this returns an integer that maps to a ScreenSize value. To learn more check out this guide on [how to create responsive layouts](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/create-responsive-layout#screen-sizes-and-breakpoints).
    - Type:  [Number]
    - Output (one of the following): 
        - 1 *(Maps to ScreenSize.Small)*
        - 2 *(Maps to ScreenSize.Medium)*
        - 3 *(Maps to ScreenSize.Large)*
        - 4 *(Maps to ScreenSize.ExtraLarge)*


## Error modal

- **Purpose**: To provide a full-screen overlay instructing users how to proceed when the application has detected an error.

- **Component name**: cmp_ErrorModal

- **Arguments**:

    ### Input

    ---

    `ModalWidth`
    - Purpose: Used to dynamically resize the Modal's width based off of the current screen width passed to it.
    - Type:  [Number]

    `ModalHeight`
    - Purpose: Used to dynamically resize the Modal's height based off of the current screen height passed to it.
    - Type:  [Number]


    `ScreenSize_Width`  
    - Purpose: An integer that maps to the [application screen sizes](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/create-responsive-layout#screen-sizes-and-breakpoints). This, alongside the ScreenSize_Height argument are used to make the text and icon elements responsive with screen size changes.
    - Type:  [Number]

    `ScreenSize_Height`
    - Purpose: An integer that maps to the [application screen sizes](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/create-responsive-layout#screen-sizes-and-breakpoints). This, alongside the ScreenSize_Width argument are used to make the text and icon elements responsive with screen size changes.
    - Type:  [Number]


    `Display_ErrorTitle`
    - Purpose: The text to display as the error modal title.
    - Type:  [Text]


    `Display_ErrorSubtitle`
    - Purpose: The text to display as the error modal subtitle.
    - Type:  [Text]


    `PrimaryColor`

    - Purpose: Color used for the textual elements.
    - Type:  [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)
    
    `BackgroundColor`

    - Purpose: Color used behind the modal.  
    - Type: [Color]
    - Expected Value: An RGBA Value ex. RGBA(0,0,0,1)

    `FocusedColor`

    - Purpose: Color used for focused elements.
    - Type:  [Color]- 
    - Expected Value:* An RGBA Value ex. RGBA(0,0,0,1)


    ### Output

    ---

    n/a


# Accessibility
## Tab index
In PowerApps most controls have a field called TabIndex. The purpose of this field is to order the keyboard navigation that someone will experience when tabbing through the application. If a control has been given a non-negative integer value then its AccessibileLabel (or Text) field will be read aloud if a screen reader is used when tabbing through the application. TabIndex's are intended to increase by one in value for each new control in order to have a defined order of tab navigation. Tab order in Buro follows the standard convention of left to right and top to bottom. [More information here](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/controls/properties-accessibility#tabindex).

## Accessible label
Given that a control has a non-negative integer value, and that this control has this property, it will be the text that is read aloud when a user has tabbed onto an item with a screen reader active. [More information here](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/controls/properties-accessibility#accessiblelabel).

## Live
This field enables Label controls to give content updates (of a its Text field value) to what is being read aloud to the screen reader. If set to "Off" changes in Label's Text field won't be read aloud. If set to "Polite" changes in Label's Text field will be read once the screen reader has finished speaking. If set to "Assertive" changes in Label's Text field will interupt the screen reader, then allow the screen reader to continue what it was saying. This specific field was leveraged when announcing updates on the state of a page in Buro. Specifically, when a page was loading and done loading this field would make assertive updates to the screen reader to let the user know when a page was fully loaded and ready for use. [More information here](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/controls/properties-accessibility#live).

# Screen responsiveness

In order to make Buro responsive to various Desktop browser and Teams window sizes, and Mobile Teams and PowerApps window sizes, custom screen resizing tools were developed.

On each screen in Buro we have a group control called grpScreenSizing``{screen name acronym}`` that holds the two controls we use to determine the application's sizing. The first control called lblScreenWidthSizing{Screen name acronym} deals with real-time updates to the width of the application, while the second control called cmpScreenFunctions``{screen name acronym}``

## Dynamic width resizing

The first control held by this group is a label control that makes use of the Parent.Size object property in PowerApps and returns it in its Text property. The Parent.Size object property compares the application's current width with the SizeBreakpoints property we supplied to the App object. The SizeBreakpoints property is a comma seperated list (array) of numerical values. These numbers represent a pixel range for different screen sizes (Small, Medium, Large, ExtraLarge). Going back to Parent.Size, what it does is return an integer based on what width the application size is (Small, Medium, Large, ExtraLarge). Based off of the knowledge of what kind of screen width is visible we can render our labels, images, galleries, etc. For more infomation [visit this page](https://powerapps.microsoft.com/en-us/blog/new-properties-for-responsive-canvas-apps/).

A working example from Buro:

- Our App.SizeBreakpoints list:

    `` [640, 900, 1200] ``

    - Application width <= 640 pixels equates to 1 (ScreenSize.Small)
    - Application width > 640 and <= 900 pixels equates to 2 (ScreenSize.Medium)
    - Application width > 900 and <= 1200 pixels equates to 3 (ScreenSize.Large)
    - Application width > 1200 equates to 4 (ScreenSize.Large)

If Buro's App.Width (the current width of the application) is 780 pixels wide, then when we call Parent.Size it will return: 2 (ScreenSize.Medium).

- *Note: We then can have the following conditional to resize the width of a text box based on the screen size the app is currently detecting.*

    ```
    100 * Switch(Parent.Size,  
            ScreenSize.Small, 1,  
            ScreenSize.Medium, 1.25,
            ScreenSize.Large, 1.5,  
            1.75
    ```

    Assuming the medium screen size of the application from the previous example, our text box will be 100 pixels * 1.25 = 125 pixels wide.

## Dynamic height resizing

The second control held by this group is a custom component we internally developed that returns a integer value denoting the screen size (Small, Medium, Large, ExtraLarge) like Parent.Size does, but for the applcation's height. As the height of the screen changes, say when running Buro in Teams and resizing the Teams window, this component keeps track of the new screen height and constantly updates its value to the current screen's size. Conversely, if the height of the screen doesn't change, like on mobile, it will still return the current screen's size and that value will then be used by other fields to responsively display the applications contents. For more information see the [cmp_ScreenFunctions section](#app-screen-height).

# Storage

In Buro we make use of two kinds of storage to handle data that we need to either persist for the lifecycle of the application, or to persist forever (as long as the application is being supported and used by people within ISED).

## Cloud storage

Due to licensing requirements, the developers decided the best path to take when considering storage would be to use the free connector PowerApps supports which is SharePoint. In a designated SharePoint site we have various lists (what we equate to SQL Tables) that we store our pertinent data in. Unlike a SQL database which should be normalized, the Sharepoint database was optimized for queries made through PowerApps in order to avoid [delegation warnings](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/delegation-overview). Each Sharepoint list employs a similar likeness to a SQL table where we have a primary key, which is a unique ID for each record in that list, and other columns of data that can range from primitive text types to SharePoint choice columns, and foreign keys to other lists. For more information on [SharePoint column types](https://support.microsoft.com/en-us/office/list-and-library-column-types-and-options-0d8ddb7b-7dc7-414d-a283-ee9dca891df7).

To create or update records in our SharePoint lists from PowerApps we use the [Patch function](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/functions/function-patch). To query our list's records we use functions like [Filter, LookUp, and Search](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/functions/function-filter-lookup). To delete records that our list has we use the [Remove or RemoveIf functions](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/functions/function-remove-removeif).

## Device storage

In addition to the cloud storage we employ in Buro, we also use device storage to temporarily hold a set of records to display to the user, or context variables to pass information to other screens of the application. For example, on the Search Screen we query for all of the desks that match the search criteria and that are not already booked. We store those results in a [collection](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/create-update-collection) the we can then sort and display to the user. Collections are stored in the application for the lifecycle of the app (the time the application is being used and open). Context variables and global variables are also used in Buro. Global variables last for the lifecycle of the application while context variables last for the lifetime of a screen. 

An example of a global variable we use is the APP_USER_DETAILS variable. In this variable we store the object returned from Office365Users.MyProfileV2() which has information about the current user's Microsoft profile. We can then use this variable across the application when we need the current user's information. 

An example of using a context variable is on the Search Screen where we store a boolean of if any error's have occured when getting the Regions, Buildings, Floors etc. from the Sharepoint lists. When the Search Screen is replaced in view by another Screen that variable will expire.

# PowerApps unit testing

PowerApps supports an experimental tool within PowerApps called Test Studio that can be used to do basic testing of parts of an application. According to the [Test Studio documentation](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/test-studio), this tool is built for making end-to-end UI tests. In Test Studio the hierarchy of tests work as follows **Test Suites > Test Cases > Test Steps**.

For Buro, each screen in the application maps to a test suite. In each test suite we have test cases with test steps to test specific functionality. All test suites and cases can be automated to run.

Due to the experimental nature of Test Studio there are limitations on what can be tested. For example, custom components we developed like the navigation bar, cannot be tested. [See this link](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/test-studio#known-limitations) for Test Studio's limitations. Another noteable limitation is that, unlike traditional unit testing, in Test Studio you cannot mock data. The inability to mock data leads to a cumbersome experience and relies on mixing testing data with production data.

In order to run tests or to create them and test accordingly. 

1. Ensure you have a record in the Users table with the `tester` field set to **Yes**

# Database reservation cleanup

In Buro, to prevent race conditions for reservations, we introduced an "ON HOLD" reservation. When a user selects a seat from the "Search Results" page, they are taken to the "Review your booking" page and automatically have an empty "ON HOLD" reservation created. Sometimes, users will not go through with a booking and choose another seat, or close the app in the meantime. Therefore, the "ON HOLD" reservations should be cleaned up occasionally.

Three Microsft Automate Flows have been create, one for each environment, to clear the "ON HOLD" reservations. If an "ON HOLD" reservation has not been modified for at least one hour, the reservation will be deleted. Access to the flows can be requested on an per-need basis.


# Supporting links and useful information  

For an overview of [powerapps](https://powerapps.microsoft.com/en-ca/).
For an overview of [sharepoint](https://www.microsoft.com/en-ca/microsoft-365/sharepoint/collaboration). For an overview of [powerapps](https://support.microsoft.com/en-us/forms). Documentation on using the office 365 connector can be found at [office-365-connector](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/connections/connection-office365-users). For [Terms, conditions, and privacy](https://www.ic.gc.ca/eic/site/icgc.nsf/eng/h_07033.html#p1) information. 

The following document was written by Microsoft and was used to help guide the development of Buro. [Coding standards and guidelines](https://pahandsonlab.blob.core.windows.net/documents/PowerApps%20canvas%20app%20coding%20standards%20and%20guidelines.pdf).

Documentation for the experimental source control tool we use for Buro. [PowerApps Language Tooling](https://github.com/microsoft/PowerApps-Language-Tooling).


    

