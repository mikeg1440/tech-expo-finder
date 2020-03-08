# Outline / Todo List
## Todo
- [X] Create a new repo
- [X] Make a README file for the repo and push to github
- [X] Choose a website to scrape data from (https://10times.com/top100/technology)
- [X] Create a outline for the project
 - [ ] States the purpose of the project
 - [ ] Includes a timeline
 - [ ] Includes goals/objectives   
 - [ ] Has a description of a minimum viable application
 - [ ] Has methods outlined & explained

> ## Outline
>> ##### General Concept  
 This will be a command line application that accepts a users location and lists the closest events coming up in the future.
>
>> ##### Objectives/goals
 - [ ] Find Website to Scrape Data from
 - [ ] Define what kind of input we want from users
 - [ ] Define methods that will be used
 - [ ] Provide descriptions for each method
 - [ ] Define what elements will be scraped
 >
 >
 >> ##### Timeline
 - Create repo
 - Create README file
 - Create outline
 - Create directories and file structure
 - Create a minimum viable application
>
>
>> ##### Methods (Minimum Viable App)
This should take a users location, look up events in that area and return a list of events with dates/times and locations
 - get_input - Gets input from user
 - scrape_data - Scrapes data from Website
 - find_events - Finds events given a location
 - display_events - Display events to user


Idea: we can use this site https://www.zipcodeapi.com/API#zipToLoc to take a user's zip code and use the timezone identifier to find events in the area

Class Structure
  - event-scraper-cli
    - scraper
      - event
        - location
