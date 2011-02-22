//根据Dopt（操作转换）算法实现的编辑操作管理类
pie.mindmap.Dopt = Class.create({
  initialize:function(mindmap,user_id){
    this.map = mindmap;
    
    this.L       = [];
    this.Q       = [];
    this.vector  = new Hash();
    this.user_id = user_id;
  },
  handle_locally_operation:function(op){
    this.generate_request(op);
    this.execute_request();
  },
  handle_remote_operation:function(){
    this.receive_request();
    this.execute_request();
  },

  generate_request:function(op){
    var r = {
      user_id : this.user_id,
      vector  : this.vector,
      op      : op
    }
    this.Q.push(r);
    this.broadcast(r);
  },

  receive_request:function(){
    if(request){
      this.Q.push(r);
    };
  },

  execute_request:function(){
    this.Q.each(function(r){
      if(this.is_executable(r)){
        r.executed = true;
        var r1 = this.dopt(r)
        this.apply_operation(r1);
        this.L.push(r1);
        this.increment(r1.user_id);
      }
    }.bind(this));
  },

  is_executable:function(r){
    var user_id = r.user_id;
    var vector  = r.vector;
    return r.vector.get(user_id) <= this.vector.get(user_id);
  },

  dopt:function(r){
    var r1 = r;
    this.L.each(function(lr){
      if(lr || r){
        r1 = this.translate_operation(r1,lr);
      }
    });
  },

  //主要算法部分
  translate_operation:function(ra,rb){
    var oa = ra.op;
    var ob = rb.op;

    var node_id_a = oa.node_id;
    var node_id_b = ob.node_id;

    var op_a = oa.op;
    var op_b = ob.op;

    var ra1;

    if(this.is_attribute_based(oa) && this.is_attribute_based(ob)){
      if(node_id_a != node_id_b || op_a != op_b){
        ra1 = ra;
        return ra1;
      }else{
        
      }


      return ra1;
    }

    if(
      (this.is_attribute_based(oa) && this.is_object_based(ob))
        ||
      (this.is_aobject_based(oa) && this.is_attribute_based(ob))
    ){
      return;
    }

    if(this.is_object_based(oa) && this.is_object_based(ob)){
      return;
    }
  }

})


