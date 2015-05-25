// JavaScript Document
$(function(){
	init();
	FlotDeOption={
		series:{
			points: {
              show: true,
			 
            },
            lines: {
			  show: true,
			  d:function(){
				 }
            }
		}
	}

	function init(){
		$.ajax({
			 url:getDataFile(),
			 dataType:"text",
			 cache:false,
			 success:function(str){
					eval('data='+str);
					$("#placeholder").css({width:data.w,height:data.h});
					options=$.extend(true, {}, FlotDeOption, data.o);
					$.plot($("#placeholder"),data.d,options);
					$(".title").html(data.title);
					$(".ptime").html(data.ptime);
					$(".that").html(data.des);
			 }
		 });	
	}
	function getDataFile(){
		return request('dataFile');
	}
	function setScrollTop(val) {
		document.documentElement.scrollTop =val;
		document.body.scrollTop =val;
	}
	function getScrollTop (){
		scrollTop = document.documentElement.scrollTop || document.body.scrollTop; 
		return scrollTop;
	}
})
