pie.form_post = function(href,method){
  var form_elm = jQuery('<form></form>')
    .attr('method', 'POST')
    .attr('action', href)
    .hide();

  var method_elm = jQuery('<input />')
    .attr('type', 'hidden')
    .attr('name', '_method')
    .attr('value', method);
    
  
  var token_elm = jQuery('<input />')
    .attr('type', 'hidden')
    .attr('name', 'authenticity_token')
    .attr('value', decodeURIComponent(decodeURIComponent(pie.auth_token)));

  form_elm.append(method_elm);
  form_elm.append(token_elm);
  jQuery(document.body).append(form_elm);

  form_elm.submit();
}