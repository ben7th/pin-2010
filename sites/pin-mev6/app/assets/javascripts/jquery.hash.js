/*
 * jQuery hash plugin used for storage hash name-value pairs
 * into browser locaiton's hash string.
 *
 * You can set or save hash name-value
 * @ $.hash("name", "value);
 *
 * You can get hash name's value
 * @ $.hash("name");
 *
 * You can delete hash name-value pairs
 * @ $hash("name", null);
 */
;
(function($){

    if ($.hash) {
        return;
    }
    
    $.hash = function(name, value){
        // jQuery doesn't support a is string judgement, so I made it by myself.
        function isString(obj){
            return typeof obj == "string" || Object.prototype.toString.call(obj) === "[object String]";
        }
        if (!isString(name) || name == "") {
            return;
        }
        
        var clearReg = new RegExp("(&" + name + "=[^&]*)|(\\b" + name + "=[^&]*&)|(\\b" + name + "=[^&]*)", "ig");
        var getReg = new RegExp("&*\\b" + name + "=[^&]*", "i");
        if (typeof value == "undefined") {
            // get name-value pair's value
            var result = location.hash.match(getReg);
            return result ? decodeURIComponent($.trim(result[0].split("=")[1])) : null;
        }
        else 
            if (value === null) {
                // remove a specific name-value pair
                location.hash = location.hash.replace(clearReg, "");
            }
            else {
                value = value + "";
                
                // clear all relative name-value pairs 
                var temp = location.hash.replace(clearReg, "");
                
                // build a new hash value-pair to save it
                temp += ((temp.indexOf("=") != -1) ? "&" : "") + name + "=" + encodeURIComponent(value);
                location.hash = temp;
            }
    };
    
})(jQuery);
