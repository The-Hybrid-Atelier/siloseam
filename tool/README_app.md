# Siloseam Design Tool
## Live App
A live version of the Siloseam Design Tool is available at:

* hybridatelier.uta.edu/apps/siloseam

## Requirements

To install on your local machine, you will need Ruby on Rails configured. 
Our implementation uses ruby 2.6.3.

```bash
# environment setup
rvm install ruby_2.6.3
rvm use ruby-2.6.3

# rails setup
cd siloseam
bundle install

# start the server
rails server

# Navigate your browser to http://localhost:3000/silicone/tool
```

## Design Files
The application view is located at: 
`http://localhost:3000/silicone/tool`

The view is located at: 
`/app/views/silicione/tool.html/haml`

Associated Javascript resources are located within:
`/app/assets/javascripts/`
and referenced through
`/app/assets/silicone.coffee`

## Usage
> 📋Give a link to where/how the pretrained models can be downloaded and how they were trained (if applicable).  Alternatively you can have an additional column in your results table with a link to the models.
