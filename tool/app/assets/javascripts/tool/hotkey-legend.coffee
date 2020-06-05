window.resolveArray = (data, template, inject)->
  injection_point = template.parent()
  template = resolveObject(data, template)
  if inject
    template.appendTo(injection_point)
  else
    return {template: template, parent: injection_point}
window.resolveObject =  (data, template)->
  template = template.clone()
  # template.data(data) 
  _.each data, (v, k)->
    template
      .attr('data-'+k, v)
      .find("[data-html='"+k+"']")
      .html(v)

    template
      .find("[data-if='"+k+"']")
      .addClass(k)

  template
    .attr("id", "")
    .removeClass('template')
  return template

class window.HotKeyLegend
  constructor: (url)->
    scope = this
    
    group_template = "#legend .cluster.template"
    key_template = ".action.template"
    
    $.ajax
      method: "GET"
      url: url
      success: (data)->
        # RESOLVE EACH CLUSTER TEMPLATE
        _.each data, (cluster)->
          node = resolveArray(cluster, $(group_template), false)
          
          # FOR EACH KEY, INJECT INTO CLUSTER TEMPLATE
          _.each cluster.keys, (action)->
            resolveArray(action, node.template.find(key_template), true)
          
          # INJECT CLUSTER TO PARENT
          node.template.appendTo(node.parent)
        
        # BIND EVENT HANDLERS
        scope.event_handlers()
        
       
        
  event_handlers: ()->
    $("#legend").find(".menu .item").click ()->
      if $(this).attr('id') == "shift-key"
        $(document).trigger("start_shift")
      else
        $(document).trigger("end_shift")
    $(".action[data-meta='shift']").hide()
    
    $(document).on "start_shift", {}, ()->
      $("#legend").find(".menu #shift-key").addClass('active')
        .siblings().removeClass('active')
      $(".action[data-meta='shift']").show()
      $(".action[data-meta!='shift']").hide()
      
    $(document).on "end_shift", {}, ()->
      $("#legend").find(".menu #shift-key").removeClass('active')
        .siblings().addClass('active')
      $(".action[data-meta='shift']").hide()
      $(".action[data-meta!='shift']").show()