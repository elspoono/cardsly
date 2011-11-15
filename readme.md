# Cardsly

The source code behind the magic.

:)

# About the Project

## The Stack
* [Coffeescript](https://github.com/jashkenas/coffee-script) by @jashkenas
* [Express](https://github.com/visionmedia/express) by @visionmedia
* [Jade](https://github.com/visionmedia/jade) by @visionmedia
* [Stylus](https://github.com/learnboost/stylus) by @learnboost

## File Structure
* `app.js`: Main app file, run `node app.js` to start app
* `public/`: Public folder, all front-end files go here
  * `css`
  * `images`
  * `js`
* `views/`: Where all Jade templates are
* `src/`: Source files, where all Coffeescript and Stylus file resides. The file structure within `src/` folder mirrors the root folder, saves time trying to hunt for files

## Compiling Files
There are a couple of helper functions defined within the `Cakefile`, which are: 
    cake watch                # Watches all Coffeescript(JS) and Stylus(CSS) files

To run `Cakefile` remember to install `coffee-script` as a global module, 

    npm install coffee-script -g
    
To compile the CSS you need to install `stylus` as a global module too in order to run the executable:
  
    npm install stylus -g
    
Then, at the root folder, just do 

    cake watch
    
And magic happens! :)