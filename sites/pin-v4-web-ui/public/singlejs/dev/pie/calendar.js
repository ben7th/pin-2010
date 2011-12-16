/** pielib Tree version 0.3
 *  (c) 2006-2008 MindPin.com - songliang
 *  this edition is build for donqu.com
 *
 *  require:
 *  scriptaculous 1.8.1 with prototype.js ver 1.6.0.3
 *
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/

/*
 * new pie.html.Inputer(element<input>,options)
 * 参数：
 * element 需要被修饰的表单项，一般是input text
 * 选项：
 * opacity 控件透明度 0~1
 * start_at 起始日期，小于这个日期的日期不能被选择
 * finish_at 终止日期，大于这个日期的日期不能被选择
 * only_month 是否只显示月份
 */
pie.html.DateInputer=Class.create();
pie.html.DateInputer.prototype={
  initialize:function(el,options){
    //options check
    options = options || {};
    Object.extend(this,options);

    this.el=$(el);

    options.updater = this.el;
    
    this.calendar = new pie.html.Calendar(options);
  },
  load:function(){
    this._load();
    return this;
  },
  _load:function(){
    this.icon = $(Builder.node("img",{
      src:"/javascripts/pie/css/calendar.gif",
      style:"padding:0 0 0 4px;"
    }));
    this.el.insert({after:this.icon});

    this.el.observe("keydown",function(evt){
      evt.stop();
    })

    //bind event
    this.icon.observe("click",function(){
      var p = this.el.cumulativeOffset();
      var d = this.el.getDimensions();
      var x = p.left;
      var y = p.top + d.height;
      
      //计算日历组件坐标
      this.calendar.load(x,y);
    }.bind(this));
  }
}


pie.html.Calendar=Class.create();
pie.html.Calendar.prototype={
  //d is a Date
  initialize:function(options){
    //options check
    options = options || {};
    Object.extend(this,options);
    
    if(this.start_at){
      //这样处理的目的是取到传入日期的 0:00 这样一个值，从而便于比较大小
      this.start_at = new Date(this.start_at);
      this.start_at = new Date(
        this.start_at.getFullYear(),
        this.start_at.getMonth(),
        this.start_at.getDate()
      );
    }
    if(this.finish_at){
      //这样处理的目的是取到传入日期的 0:00 这样一个值，从而便于比较大小
      this.finish_at = new Date(this.finish_at);
      this.finish_at = new Date(
        this.finish_at.getFullYear(),
        this.finish_at.getMonth(),
        this.finish_at.getDate()
      );
    }
    if(this.only_month==null){
      this.only_month==false;
    }

    this.format = options.format||(this.hidehours?"yyyy-MM-dd":"yyyy-MM-dd hh:mm")

    //日志
    this.log = function(){};
    //this.log = new pie.Logger().get("debugger");

    //params
    this.month_des=[
      "一月",
      "二月",
      "三月",
      "四月",
      "五月",
      "六月",
      "七月",
      "八月",
      "九月",
      "十月",
      "十一月",
      "十二月"
    ];

    this.isload=false;
  },
  fillDateTable:function(_year,_month,_day){
    //get ready
    var month,year,day;

    if(typeof _year == "object"){
      month=_year.getMonth()+1;
      day=_year.getDate();
      year=_year.getFullYear();
    }else{
      month=_month;
      day=_day;
      year=_year;
    }

    this._fillYearMonth(year,month);

    //get first day of the month
    var first_date=new Date(year,month-1,1);
    //get the weekday of this day
    var first_weekday=first_date.getDay();
    if(first_weekday==0||first_weekday==1){first_weekday+=7};
    //create a array of length 42
    var arr=[];
    var arr1=[];

    var dayflag=-1;
    var b=2-first_weekday;

    for(var i=0;i<42;i++){
      var temp=new Date(year,month-1,b+i);
      arr[i]=temp;
      if((month-1)!=temp.getMonth()){
        arr1[i]=false;
      }else{
        arr1[i]=true;
        if(-1==dayflag){
          if(day==temp.getDate()){
            dayflag=i;
          }
        }
      }
    }

    //fill in the table
    //"tm" => "this month"
    //"ntm" => "not this month"
    var now=new Date();
    this.grids.each(function(tr,index){
      $A(tr.getElementsByTagName("td")).each(function(td,j){
        i=index+1;
        //is it in this month?
        var c=arr1[(i-1)*7+j]?"tm":"ntm";
        
        //is it the selected day?
        c=((i-1)*7+j==dayflag)?"day":c;
        
        if(this.start_at){
          if(arr[(i-1)*7+j]<this.start_at){
            c+=" disable"
          }
        }
        if(this.finish_at){
          if(arr[(i-1)*7+j]>this.finish_at){
            c+=" disable"
          }
        }

        //is it today?
        var st="";
        if((c=="tm")||(c=="day")){
          if(now.getFullYear()==year){
            if(now.getMonth()==month-1){
              if(now.getDate()==arr[(i-1)*7+j].getDate()){
                st="border:solid 1px darkred; text-decoration:underline;"
              }
            }
          }
        }
        
        $(td).update("<a href='javascript:void(0)' class='"+c+"' style='"+st+"' hidefocus='on'>"+arr[(i-1)*7+j].getDate()+"</a>");
        
      }.bind(this));
    }.bind(this));
  },
  _fillYearMonth:function(year,month){
    //change year view
    $(this.yearpanel.getElementsByTagName("span")[0]).update(year);
    //change month view
    if(this.only_month){
      $(this.monthpanel.getElementsByTagName("span")[0]).update(year+"-"+((month<10)?"0"+month:month));
    }else{
      $(this.monthpanel.getElementsByTagName("span")[0]).update(this.month_des[month-1]);
    }

    //如果设置了起始时间，则适时的隐藏掉按钮
    if(this.start_at){
      var start_m=new Date(
        this.start_at.getFullYear(),
        this.start_at.getMonth()
      );
      //年
      if(new Date(year-1,month) <= start_m){
        $(this.yearpanel.getElementsByTagName("label")[0]).addClassName("disable");
      }else{
        $(this.yearpanel.getElementsByTagName("label")[0]).removeClassName("disable");
      }
      //月
      if(new Date(year,month-1) <= start_m){
        $(this.monthpanel.getElementsByTagName("label")[0]).addClassName("disable");
      }else{
        $(this.monthpanel.getElementsByTagName("label")[0]).removeClassName("disable");
      }
    }

    //如果设置了终止时间，则适时的隐藏掉按钮
    if(this.finish_at){
      var finish_m=new Date(
        this.finish_at.getFullYear(),
        this.finish_at.getMonth()
      );
      this.log(year+","+month+","+new Date(year,month-1).getFormatValue("yyyy-MM-dd")+","+finish_m.getFormatValue("yyyy-MM-dd"));
      //年
      if(new Date(year+1,month-1) > finish_m){
        $(this.yearpanel.getElementsByTagName("label")[1]).addClassName("disable");
      }else{
        $(this.yearpanel.getElementsByTagName("label")[1]).removeClassName("disable");
      }
      //月
      if(new Date(year,month) > finish_m){
        $(this.monthpanel.getElementsByTagName("label")[1]).addClassName("disable");
      }else{
        $(this.monthpanel.getElementsByTagName("label")[1]).removeClassName("disable");
      }
    }
  },
  changeYear:function(yc){
    this.date.setYear(this.date.getFullYear()+yc);
    this.fillDateTable(this.date);
  },
  changeMonth:function(mc){
    var m1=this.date.getMonth();
    this.date.setMonth(m1+mc);
    var m2=this.date.getMonth();
    if((m2-m1)%12>mc)
    this.date.setDate(0);
    this.fillDateTable(this.date);
  },
  setValue:function(date){
    if(this.start_at){
      date = date<this.start_at?this.start_at:date;
    }
    this.date=date;
    this.fillDateTable(this.date);
  },
  toToday:function(){
    this.date=new Date();
    this.fillDateTable(this.date);
  },
  getValue:function(){
    return this.date;
  },
  getFormatValue:function(){
    var date = this.date;
    if(!this.hidehours){
      date.setHours(this.hour_selector.value,this.minute_selector.value);
    }
    var d=date.getFormatValue(this.format);
    return d;
  },
  _loadFromUpdater:function(){
    //需要为支持多种日期格式优化逻辑
    var timestr;
    var vd;
    var hour;
    var minute;
    var ipt=$(this.updater);
    //"yyyy-MM-dd hh:mm"
    var reg=/^\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}$/;
    var regig=/(\d{4})\-(\d{2})\-(\d{2}) (\d{2})\:(\d{2})/ig;
    if(this.hidehours){
      //yyyy-MM-dd
      reg=/^\d{4}\-\d{2}\-\d{2}$/;
      regig=/(\d{4})\-(\d{2})\-(\d{2})/ig;
    }

    if("INPUT"==ipt.tagName){
      timestr=ipt.value;
    }else{
      timestr=ipt.innerHTML;
    }

    if(reg.test(ipt.value)){
      vd=new Date(timestr.replace(regig,"$1/$2/$3"));
      if(!this.hidehours){
        hour=parseInt(timestr.replace(regig,"$4"),10);
        minute=parseInt(timestr.replace(regig,"$5"),10);
      }
    }else{
      vd=new Date();
      hour=7;
      minute=0;
    }
    
    this.setValue(vd);
    if(!this.hidehours){
      this.hour_selector.options[hour].selected=true;
      this.minute_selector.options[minute/15].selected=true;
    }
  },
  _fillUpdater:function(){
    //fill in updater
    if(this.updater){
      this.unload();
      var ipt=$(this.updater);
      if("INPUT"==ipt.tagName){
        ipt.value=this.getFormatValue();
      }else{
        ipt.innerHTML=this.getFormatValue();
      }
    }
  },
  init:function(){
    this.el.makeUnselectable();
    
    this.log("init..")

    if(this.updater){
      this._loadFromUpdater();
    }else{
      this.setValue(new Date());
    }

    this.grids.each(function(tr){
      $A(tr.getElementsByTagName("td")).each(function(td){
        $(td).observe("click",function(evt){
          evt.stop();
          var a=$(td.firstChild);
          //如果当前日期不可选择，忽略
          if(a.hasClassName("disable")){
            return false;
          }
          //如果不是当前月，判断是上月还是下月
          var ih=a.innerHTML;
          //根据className判断是否当前显示月的日期
          if(a.className=="ntm"){
            if(ih>15){
              this.date.setMonth(this.date.getMonth()-1);
            }else{
              this.date.setMonth(this.date.getMonth()+1);
            }
          }
          this.date.setDate(ih);

          this.setValue(this.date);

          this._fillUpdater();
        }.bind(this));
      }.bind(this))
    }.bind(this));
    this.log("init finished")
  },
  load:function(x,y){
    this._load(x,y);
    this.init();
    return this;
  },
  _load:function(x,y){
    //Create a Div Obj , if it is not exist
    var c;
    if(this.el){
      this.log("load calendar cache");
      c=this.el;
    }else{
      this.log("create calendar element")

      //年份选择区域
      this.lastyear=$(Builder.node("label","<<"));
      this.nextyear=$(Builder.node("label",">>"));
      this.yearpanel=$(Builder.node("div",{
        "class":"p_h_c_y"
      },[
        this.lastyear,
        Builder.node("span"),
        this.nextyear
      ]));

      //月份选择区域
      this.lastmonth=$(Builder.node("label",Builder.node("a",{href:"javascript:void(0)"},"<")));
      this.nextmonth=$(Builder.node("label",Builder.node("a",{href:"javascript:void(0)"},">")));
      this.monthpanel=$(Builder.node("div",{
        "class":this.only_month?"p_h_c_om":"p_h_c_m"
      },[
        this.lastmonth,
        Builder.node("span"),
        this.nextmonth
      ]));

      if(this.only_month){
        this.yearpanel.hide();
      }

      //日期单元格
      this.grids=[];
      for(var i=0;i<6;i++){
        var tr=Builder.node("tr",[
          Builder.node("td"),
          Builder.node("td"),
          Builder.node("td"),
          Builder.node("td"),
          Builder.node("td"),
          Builder.node("td",{"class":"sat"}),
          Builder.node("td",{"class":"sun"})
        ])
        this.grids.push(tr);
      }

      //日期选择区域
      this.table=$(Builder.node("table",{
        "border":0,"cellspacing":0,"cellpadding":0,"class":"p_h_c_d"
      },Builder.node('tbody',[
        Builder.node("tr",{
          "class":"wday"
        },[
          Builder.node("td","一"),
          Builder.node("td","二"),
          Builder.node("td","三"),
          Builder.node("td","四"),
          Builder.node("td","五"),
          Builder.node("td",{"class":"saturday"},"六"),
          Builder.node("td",{"class":"sunday"},"日")
        ]),
        this.grids
      ])));

      this.hours=[];
      for(var i=0;i<=23;i++){
        var o = Builder.node("option",{"value":i},(i<10?"0"+i:i)+":00");
        this.hours.push(o);
      }

      //小时选择器
      this.hour_selector=$(Builder.node("select",{},this.hours));
      this.hour_selector.options[7].selected=true;

      this.minutes=[]
      for(var i=0;i<=45;i+=15){
        var o = Builder.node("option",{"value":i},(i<10?"0"+i:i)+"\'");
        this.minutes.push(o);
      }

      //分钟选择器
      this.minute_selector=$(Builder.node("select",{},this.minutes));
      this.minute_selector.options[0].selected=true;

      var hour_and_minute=["@",this.hour_selector,"-",this.minute_selector];

      //如果选择了隐藏小时选择，则不显示
      if(this.hidehours){
        hour_and_minute=[];
      }

      //“今天”按钮
      this.todaybotton=$(Builder.node("a",{href:"javascript:void(0)","class":"today"},"今天"));
      this.todaypanel=$(Builder.node("div",{
        "class":"p_h_c_b"
      },[hour_and_minute,this.todaybotton]));

      //如果选择了隐藏小时选择，则“今天”居中对齐
      if(this.hidehours){
        this.todaypanel.style.textAlign="center";
      }

      c=$(Builder.node("div",{
        id:Math.random(),
        "class":"p_h_c"
      },[this.yearpanel,this.monthpanel,this.table,this.todaypanel]));

      //bind event
      //previous year
      this.lastyear.observe("click",function(evt){
        this.changeYear(-1);
        evt.stop();
      }.bind(this));

      this.nextyear.observe("click",function(evt){
        this.changeYear(1);
        evt.stop();
      }.bind(this));

      this.lastmonth.observe("click",function(evt){
        this.changeMonth(-1);
        evt.stop();
      }.bind(this));

      this.nextmonth.observe("click",function(evt){
        this.changeMonth(1);
        evt.stop();
      }.bind(this));

      //get today
      this.todaybotton.observe("click",function(evt){
        this.toToday();
      }.bind(this))

      c.observe("mousedown",function(evt){
        evt.stop();
      })

      //click on anywhere , unload
      document.observe("mousedown",function(evt){
        this.unload();
      }.bind(this));

      //click calendar , do nothing
      c.observe("click",function(evt){
        evt.stop();
      });
      
      this.log("dom created")
      this.el=c;
    }

    this.el.setStyle({
      left:x+"px",
      top:y+"px",
      opacity:this.opacity
    })
    document.body.appendChild(this.el);
    this.isload=true;
  },
  //Remove all Calendar dom from document
  unload:function(){
    if (this.isload) {
      this.el.remove();
      this.isload=false;
    }
  }
}