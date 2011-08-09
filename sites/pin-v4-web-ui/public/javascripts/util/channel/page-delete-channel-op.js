pie.load(function(){
  jQuery('.page-channel-meta-title .op .delete').click(function(){
    //  删除频道
    //  delete /channels/:id
    var elm = jQuery(this);
    var channel_id = elm.domdata('id');
    var href = elm.domdata('to-href');

    elm.confirm_dialog('确定删除吗',function(){
      pie.form_post('/channels/'+channel_id , 'delete');
    })
  })
})

