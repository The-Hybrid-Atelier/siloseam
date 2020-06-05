Siloseam Tool
=========

This application takes an annotated SVG files and produces SVGs for custom bladder molds. 

We keep a running version of this Rails app on our server at: 

* [Siloseam App](https://hybridatelier.uta.edu/apps/siloseam)

## Contributors

* Cesar Torres
* Hedieh Moradi

## Dependencies

* A Ruby on Rails environment (we used ruby 2.4.0). We recommend using RVM (`rvm install 2.4.0; rvm use 2.4.0`).


## Installation Instructions
Run
`rake secret`
Copy and paste the generated hash into your bashrc file as follows:
`export MY_SECRET_BASE=<generated_hash>`
Restart your terminal for the changes to take effect.

Run: 
```
bundle install
rails server
```
Open a web browser (we recommend Chrome) and point it to: 
`localhost:3000`

## How to Use the Tool
Check out our instructable and YouTube video going through the process. 
* https://www.instructables.com/id/Inflatable-Silicone-Octopus/

[![How to use Siloseam](http://img.youtube.com/vi/BlMqOIE3d1k/0.jpg)](http://www.youtube.com/watch?v=BlMqOIE3d1k "")

## Troubleshooting

* mySQL not installing during `bundle install`? Try installing dependencies through brew: `brew install msql` then rerun `bundle install`.  

