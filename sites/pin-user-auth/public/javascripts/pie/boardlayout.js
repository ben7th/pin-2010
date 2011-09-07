var boardLayout={
  columnCount:4,
  columns:0,
  columnWidthInner:193,
  columnMargin:16,
  columnPadding:28,
  columnContainerWidth:0,
  pinsContainer:".BoardLayout",
  pinArray:[],

  allPins:function(){
    var a = document.documentElement.clientWidth;
    this.columnWidthOuter = this.columnWidthInner + this.columnMargin + this.columnPadding;
    this.columns = Math.max(this.columnCount, parseInt(a/this.columnWidthOuter));
    a = this.columnWidthOuter*this.columns-this.columnMargin;
    document.getElementById("profile")&&this.columns--;
    document.getElementById("wrapper").style.width=a+"px";
    for(a=0;a<this.columns;a++){
      this.pinArray[a]=0;
    }
    if(document.getElementById("boardMetadata")){
      this.pinArray[this.columns-1]=document.getElementById("boardMetadata").offsetHeight+this.columnMargin;
    }
    a=$(this.pinsContainer+" .pin");
    document.getElementById("slk_sort_boards") ? this.showPins() : this.flowPins(a)
  },

  newPins:function(){
    this.flowPins($(this.pinsContainer+":last .pin"))
  },

  flowPins:function(a){
    for(i=0;i<a.length;i++){
      var 
        e = a[i],
        d = jQuery.inArray(Math.min.apply(Math,this.pinArray),this.pinArray),
        g = this.pinArray[d];
        
      e.style.top = g+"px";
      e.style.left = d*this.columnWidthOuter+"px";
      e.id="col" + d%this.columns;
      
      this.pinArray[d]=g+e.offsetHeight+this.columnMargin
    }
    document.getElementById("ColumnContainer").style.height=Math.max.apply(Math,this.pinArray)+"px";
    this.showPins()
  },

  showPins:function(){
    $.browser.msie&&parseInt($.browser.version)==7||$(this.pinsContainer).animate({opacity:"1"},300)
  }
};