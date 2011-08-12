/**
 * Created by .
 * User: zhuwenxuan
 * Date: 11-5-30
 * Time: 上午11:02
 */


baidu.editor.commands['time'] = {
    execCommand : function() {
        var date = new Date,
            min = date.getMinutes(),
            sec = date.getSeconds(),
            arr = [date.getHours(),min<10 ? "0"+min : min,sec<10 ? "0"+sec : sec];
        this.execCommand('insertHtml',arr.join(":"));
        return true;
    }
};
baidu.editor.commands['date'] = {
    execCommand : function() {
        var date = new Date,
            month = date.getMonth()+1,
            day = date.getDate(),
            arr = [date.getFullYear(),month<10 ? "0"+month : month,day<10?"0"+day:day];
        this.execCommand('insertHtml',arr.join("-"));
        return true;
    }
};
//baidu.editor.contextMenuItems.push({
//    group : '插入时间',
//    subMenu : [
//        {
//            label: '插入日期',
//            cmdName : 'date'
//        },
//        {
//            label: '插入时间',
//            cmdName : 'time'
//        }]
//});



