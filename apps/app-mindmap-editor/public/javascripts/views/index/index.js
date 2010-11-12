$(document).ready(function(){
	$('.tips a').hover(function(){
		$(this).find('.tips-info').addClass('bg');
	},function(){
		$(this).find('.tips-info').removeClass('bg');
	});
	
	$('#demo-div a,#signup-div a').hover(function(){
		$(this).find('#demo-tips,#signup-tips').addClass('bg');
	},function(){
		$(this).find('#demo-tips,#signup-tips').removeClass('bg');
	});
});
