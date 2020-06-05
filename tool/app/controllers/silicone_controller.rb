class SiliconeController < ApplicationController
  
  def tool
    @files = get_primitives()
    render :layout => "full_screen"
  end
  def keys
    legend = 
      [
        {
          key_cluster: "Siloseam Operations",
          keys: [
            {icon: "1", key: "1", meta: "", action: "outline", help: ""},
            {icon: "2", key: "2", meta: "", action: "generate", help: ""},
            {icon: "3", key: "3", meta: "", action: "stylize", help: ""},
            # {icon: "3", key: "3", meta: "", action: "generate", help: ""},
            {icon: "a", key: "a", meta: "", action: "assign", inputize: "text", help: ""}
            
          ]
        },
        {
          key_cluster: "Path Operations",
          keys: [
            {icon: "i", key: "i", meta: ""     , action: "invert_path", help: ""},
            {icon: "u", key: "u", action: "unite", help: "Unions two or more paths."},
            {icon: "s", key: "s", action: "subtract", help: "Subtracts two or more paths."}
          ]
        },
        {
          key_cluster: "Ordering Operations",
          keys: [
            {icon: "{", key: "{", meta: "shift"     , action: "bring_to_front", help: ""},
            {icon: "}", key: "}", meta: "shift"     , action: "send_to_back", help: ""}
          ]
        },
        {
          key_cluster: "Basic Operations",
          keys: [
            {icon: "⌫", key: "backspace", meta: "", action: "delete", help: ""},
            {icon: "⌫", key: "backspace", meta: "shift", action: "clear all", help: ""},
            {icon: "up", key: "up", meta: "shift"     , action: "scale up", help: ""},
            {icon: "down", key: "down", meta: "shift"     , action: "scale down", help: ""},
            {icon: "left", key: "left", meta: "shift"     , action: "rotate ccw", help: ""},
            {icon: "right", key: "right", meta: "shift"     , action: "rotate cw", help: ""},
            {icon: "r", key: "r", meta: "shift"     , action: "reflect y", help: ""},
            {icon: "r", key: "r", meta: ""     , action: "reflect x", help: ""},
            {icon: "d", key: "d", meta: ""     , action: "duplicate", help: ""}
          ]
        }
      ]
      
    render :json => legend
  end
  # HELPER METHODS
  def get_primitives
    files = {path: "/primitives/", filenames: Dir.glob("public/primitives/*").collect!{|c| c.split('/')[2..-1].join('/')}}
    files[:filenames].collect!{|f| {:collection => f.split('.')[0].split('-')[0].split('_')[0].titlecase, :filename => f, :title => f.split(".")[0].titlecase}}
    files
  end
  
end
