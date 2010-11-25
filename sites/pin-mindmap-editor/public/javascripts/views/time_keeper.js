TimeKeeper = Class.create({
  initialize : function(url){
    this.url = url;
    this.frequence = 0;
    this.ave_time = 0;
    this.total_time = 0;
    this.request_per_half_minute();
  },
  request_per_half_minute : function(){
    new PeriodicalExecuter(function() {
      var begin_time = new Date();
      new Ajax.Request(this.url,{
        method: 'get',
        onSuccess:function(response){
          var respond_time = (new Date()-begin_time);
          this.total_time = this.total_time + respond_time;
          this.frequence = this.frequence + 1;
          this.ave_time = this.total_time/this.frequence;
          $$("#net_condition .last_respond span.time")[0].update(respond_time)
          $$("#net_condition .average_respond span.time")[0].update(Math.round(this.ave_time))
        }.bind(this)
      })
    }.bind(this), 30);
  }
});


