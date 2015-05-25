// JavaScript Document
$(function(){
	var ListSccrollTop;
	var GlobalAjax;
	var bakinterval;
	var windowWidth=$(window).width();
	
	
	$("#NewsList a").live("tap",function(event){
		
		
		ContentUrl=$(this).attr("href");
		ContentUrl=ContentUrl.replace('./NewsContent.html?dataFile=','');
		if (ContentUrl.indexOf("wisp://") != 0)
		{
			$("#NewsList a").live("click",function(event){
				event.preventDefault();
				return false;
			})
			location.hash ="#content";
			bakinterval=setInterval("checkHash()",100);
			event.preventDefault();
			scrollTop=getScrollTop();
			ListSccrollTop=scrollTop;
			$("#NewsContent").css({"margin-left":"0","margin-top":scrollTop});
			$("#NewsList").css("marginLeft","-100%");
			setTimeout(function(){
							setScrollTop(0);
							$("#NewsContent").css("margin-top","0px");
							$(".back").show();
							$("#pageContent").height($("#NewsContent").height());
							try{GlobalAjax.abort();}catch(e){}
							$("#NewsContent").find(".content").empty();
							GlobalAjax=$.ajax({
								 url:ContentUrl,
								 dataType:"json",
								 cache:false,
								 success:function(data){
										html=template.render('NewContentHtml',data);
										$("#NewsContent").find(".content").html(html);
										$("#pageContent").height($("#NewsContent").height());
										$("#NewsContent img").bind("load",function(){
											 
												$("#pageContent").height($("#NewsContent").height());
										});
										//$("#pageContent").height($(window).height());
								 }
							 })
					},500)
			return false;
		}else
		{
			//location.href =ContentUrl;
			$("#NewsList a").die("click");
		}
		
	})

	$("#NewsList a").live("click",function(event){
			event.preventDefault();
			return false;
	})
	
	$(".back").live("tap",function(){
		$("#NewsList a").live("click",function(event){
			event.preventDefault();
			return false;
		})
		$(".back").hide();
		try{clearInterval(bakinterval);}catch(e){}
		location.hash ="";
		$("#loadError").hide();
		$("#pageContent").height($("#NewsList").height());
		$("#NewsContent").css("margin-top",ListSccrollTop);
		setScrollTop(ListSccrollTop);
		$("#NewsContent").css("margin-left","100%");
		$("#NewsList").css("marginLeft","0%");		
		return  false;
	})
	
	
	
	$(".gdt ul li").live("touchstart",function(event){
		 gdtmovestart=false;
		 touch = {};
		 if (event.touches.length == 1)
		 {
			// event.preventDefault(); 
			 touch.x1 = event.touches[0].pageX;
			 touch.y1 = event.touches[0].pageY;
			 touch.estat=parseInt($(".gdt ul").css("margin-left"));
			 touch.mlmax= windowWidth * ( $(".gdt ul li").length/2 -1) *-1;
			 gdtmovestart=true;
		 }
	}).live("touchmove",function(event){
		 if (event.touches.length == 1)
		 {
			// event.preventDefault();
			 if (gdtmovestart != true)
			 {
			   touch.x1 = event.targetTouches[0].pageX;
			   touch.y1 = event.targetTouches[0].pageY;
			   gdtmovestart=true;
			 }
			 touch.x2 = event.targetTouches[0].pageX;
			 touch.y2 = event.targetTouches[0].pageY;
			 touch.xc = touch.x2 - touch.x1;
			 LmarginLeft=touch.estat + touch.xc;
			 LmarginLeft = LmarginLeft > 0 ? 0 : LmarginLeft;
			 LmarginLeft = LmarginLeft < touch.mlmax ? touch.mlmax : LmarginLeft;
			 $(".gdt ul").css("margin-left",LmarginLeft +'px');
		 }
	}).live("touchend",function(event){
		 if (gdtmovestart == true)
		 {
			marginLeft=parseInt($(".gdt ul").css("margin-left"));
			if ( Math.abs( touch.xc) > 100)
			{
				if (touch.xc < 0)
				{
					LmarginLeft = touch.estat - windowWidth;
				}else
				{
					LmarginLeft = touch.estat + windowWidth;
				}
			}else
			{
				LmarginLeft=marginLeft-marginLeft%windowWidth;
			}
			LmarginLeft = LmarginLeft > 0 ? 0 : LmarginLeft;
			LmarginLeft = LmarginLeft < touch.mlmax ? touch.mlmax : LmarginLeft;
			$(".gdt ul").animate({"marginLeft": LmarginLeft+'px'},100);
			Index=Math.abs(LmarginLeft/windowWidth);
			$(".dian p span").removeClass("move").eq(Index).addClass("move");
			$(".dian b").text($(".gdt ul li img").eq(Index).attr("alt"));
		 }
	
	});
	$(".anniu").live("tap click",function(event){
		   $("#NewsList a").live("click",function(event){
				event.preventDefault();
				return false;
			})
		   event.preventDefault();
		   $(".anniu").hide();
		   DataUrl=$(this).attr("data-url");
		  
		  $.ajax({
			 url:DataUrl,
			 dataType:"json",
			 cache:false,
			 async:false,
			 success:function(data){
					html=template.render('NewsListAdd',data);
					$("#NewsList").find('.he').append(html);
					if (data.config.showmore != true)
					{
						$(".anniu").remove();
					}else
					{
						$(".anniu").attr("data-url",data.config.nextData).show();
					}
					$("#pageContent").height($("#NewsList").height());
					
			 }
		 });
	
	   return false;
	
	});
	
	
	
	init();
	function init(){
		$.ajax({
			 url:getDataFile(),
			 dataType:"json",
			 cache:false,
			 success:function(data){
					html=template.render('NewListHtml',data);
					$("#NewsList").html(html);
					$(".dian p").empty();
					$(".dian b").text($(".gdt ul li img").eq(0).attr("alt"));
					$(".gdt ul li img").eq(0).bind("load",function(){
						$(".gdt ul li img").css("width",windowWidth);
						$(".gdt ul li").css("width",windowWidth);
						$(".gdt ul li img").css("height",$(this).height());
						$(".gdt").css("height",$(this).height());
						$(".gdt ul").css("width","10000px");
						$("#pageContent").height($("#NewsList").height());
					});
					if ($(".gdt ul li").length > 1)
					{
						for(i=0;i<$(".gdt ul li").length;i++)
						{
							$("<span></span").appendTo(".dian p");
						}
						$(".dian p span").eq(0).addClass("move");
						$(".gdt ul li").clone().appendTo(".gdt ul");
					}
					$("#pageContent").height($("#NewsList").height());
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

function checkHash(){
	hash=location.hash;
	if (hash != "#content" )
	{
		$(".back").trigger("tap");
	}
}
