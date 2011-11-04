/*
  距离现在一分钟以内  -> xx 秒前
  距离现在一小时以内  -> xx 分钟前
  今天以内           -> 今天 几点几分
  不是今天           -> 几月几日 几点几分
  不是今年           -> 几年 几月几日 几点几分
 **/
(function(){
  function friendly_relative_time(timestamp_date){
    var current_date = new Date();
    var current_date_millisecond = current_date.valueOf();
    var timestamp_date_millisecond = timestamp_date.valueOf();
    var relative_millisecond = current_date_millisecond - timestamp_date_millisecond;

    if(relative_millisecond < 0){
      return "1秒前";
    }
    if(relative_millisecond < 60000){
      return parseInt(relative_millisecond/1000) + "秒前";
    }
    if(relative_millisecond < 3600000){
      return parseInt(relative_millisecond/60000) + "分钟前";
    }
    if(relative_millisecond < 86400000 && timestamp_date.getDate()==current_date.getDate()){
      return timestamp_date.getHours() +":"+ timestamp_date.getMinutes();
    }
    if(timestamp_date.getYear() == current_date.getYear()){
      return (timestamp_date.getMonth()+1) +"月"+timestamp_date.getDate()+"日 "+timestamp_date.getHours()+":"+timestamp_date.getMinutes();
    }
    return timestamp_date.getFullYear()+"年"+(timestamp_date.getMonth()+1) +"月"+timestamp_date.getDate()+"日 "+timestamp_date.getHours()+":"+timestamp_date.getMinutes();
  }

  jQuery.fn.extend({
    refresh_time: function(){
      this.each(function(){
        var dom = jQuery(this);
        var timestamp = dom.attr("data-date");
        if(!timestamp){
          return;
        }
        var timestamp_date = new Date();
        timestamp_date.setTime(timestamp*1000);
        var friendly_time = friendly_relative_time(timestamp_date);
        dom.text(friendly_time);
      });
    }
  });

  jQuery(document).ready(function(){
    setInterval(function(){
      jQuery("span[data-date]").refresh_time();
    },30000);
  });
})();


