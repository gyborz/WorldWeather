

WorldWeather

A regular weather app in which the user can get information about his/her current location's or a searched city's weather. 
The user can search for a location by the city's name or with the help of a map.

Technologies: Swift, UIKit, SwipeCellKit, SwiftyJSON

Third party libraries I used:

- for the swiping/deleting mechanism on the table view cells:
https://github.com/SwipeCellKit/SwipeCellKit

- for handling the json (mainly for better code readability):
https://github.com/SwiftyJSON/SwiftyJSON

The api for getting the weather data (using the free version):
https://openweathermap.org/api


<a href="https://apps.apple.com/app/id1491605325" rel="some text">![download](https://user-images.githubusercontent.com/44786735/70862038-112c4e00-1f37-11ea-9694-7b46c3404b3a.png)</a>

The first tab is all about the user's current location. The app shows the city, the temperature, some detailed information
about the weather (pressure, wind speed, etc.), gives a forecast for the next 24 hours and below that a forecast for the 
next 4 days. 
The background changes too according to the weather conditions.

![firsttab](https://user-images.githubusercontent.com/44786735/63839354-6855e500-c97f-11e9-9eb4-7ed376afc0ea.png)


On the second tab the user can search for a location by name (+ country code for more accurate search) and then a new 
card-like view appears with the requested city. On the card the layout is different but the same informations are shown
as on the first tab.
The city will be stored in the second tab's list where all the previously searched locations and their actual weather 
can be seen. The user can tap on them and the card appears with the current conditions, or the user can delete them.
There's also a temperature unit control button for changing from Celsius to Fahrenheit or vice versa.

![secondtab](https://user-images.githubusercontent.com/44786735/66338214-f4750800-e940-11e9-9b35-1a9bbc631419.png)


On the third tab a map shows the user's location. The user can freely move around and pin down an annotation with a long press.
If there's an annotation then the user can request the location's weather information with pressing the appearing button.
There's also a search button which upon tapping makes a searchbar appear, so the user has another way of searching 
locations and get their weather.

![thirdtab](https://user-images.githubusercontent.com/44786735/66338397-4fa6fa80-e941-11e9-9bce-3d33cb5dee44.png)


