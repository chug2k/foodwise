Foodwise
========

Foodwise is a cool app. There are more details to come.

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
