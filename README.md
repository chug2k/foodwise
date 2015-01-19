Foodwise
========

![Awesome Logo](/admin/public/img/logo.png?raw=true)

Currently running as two modular Sinatra apps running off of Rack - one for the API and one for the Admin Frontend. 

## General Architecture

This repo houses two different modular Sinatra Applications, both in the `Foodwise` namespace. One is called `Api`, and the other is called `Admin`. There is a shared models directory, which the `Admin` app never imports (for maximum modularity). The `Admin` class is mostly written to serve as an example of an API consumer.

The API uses token-based authentication, which it reads from a 'Foodwise-Token' header.

## Installation Instructions

* Clone this repository.
* Run `bundle install`. 
* Run `bundle exec rackup -p 9393`.
* Create a user, by running `rake create_fake_user`. You'll likely want at least one user to have admin privileges - run `tux` from the command line (or use regular SQL magic) to set the `is_admin` column to `true`.
* Optionally, create a product by running `rake create_fake_user`.

## Usage Instructions

You can verify that the API is alive by going to `/api`. You should be greeted with something like

    Hello World! It is currently 2014-12-29 07:46:34 +0000
    
To check out the admin frontend, go to `/admin`. Remember you probably want to login with a user who has `is_admin` set to `true`.

## Deployment

The app is set up to run on Heroku, using the unicorn webserver. It currently runs on `foodwise.herokuapp.com`. Environment variables should be correctly set; no special magic required here.

## Populating Data

The app is set up to populate from two sources: Nutritionix and local `.xlsx` files. I use the `creek` gem as it's a stream-based parser, and the input worksheets tend to be huge. There's the initial one checked in at `/data/yogurt-data.csv`, which has a lot more than yogurt in it. To import: 

```
rake import_excel
```` 

As of this writing, I only import the first sheet, because I haven't implemented pagination on the API just yet. 

The import from Nutritionix, you use the `import_nutritionix` rake task. You have to manually pass in the Nutritionix ids, right now, but you can do it from the command line.

```
rake import_nutritionix[51c3ffe997c3e6dfa4df3270,51c3727297c3e69de4b0b60e,53f1f885d442da5d31289640]
```

Obviously in production, use `heroku run rake ...`. 

## More about the API

Head to foodwise.apiary.io for more details!
