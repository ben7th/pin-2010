pie.load(function(){
  new pie.HomepageNewCount().run();
});

pie.HomepageNewCount = Class.create({
  initialize:function(){
    this.new_feed_div     = jQuery('.show_new_feed');
    this.new_feed_link    = jQuery('.show_new_feed a');
    this.new_feed_loading = jQuery('.loading_new_feed');
    this._bind_new_feed_link_event();
  },
  _bind_new_feed_link_event:function(){
    this.new_feed_link.bind('click',function(){
      var newest_li = jQuery('.mplist.feeds .feed')[0];
      var after = newest_li.id.split('feed_')[1];
      this.new_feed_loading.show();
      this.new_feed_div.hide();
      jQuery.ajax({
        url     : '/newsfeed/get_new_feeds',
        data    : 'after='+after,
        success : function(res){
          var children = jQuery(res).children().hide();
          jQuery(newest_li).before(children);
          children.fadeIn(800);
        }.bind(this),
        complete : function(res){
          this.new_feed_loading.hide();
        }.bind(this)
      })
    }.bind(this));
  },
  run:function(){
    this.runner = new PeriodicalExecuter(function(){
      jQuery.ajax({
        url     : "/news/unread_count",
        success : function(res){
          this._onsuccess(res);
        }.bind(this)
      });
    }.bind(this),15);
  },
  stop:function(){
    this.runner.stop();
  },
  _onsuccess:function(res){
    var feed      = res.feed;
    var attention = res.attention;
    if(feed > 0){
      this.new_feed_div.slideDown(100);
    }
  }
})