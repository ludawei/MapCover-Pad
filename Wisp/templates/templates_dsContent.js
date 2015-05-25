// JavaScript Document
var globalAjax;
// 获取URL的参数
$(function(){
	if (window.localStorage)
	{
		ls=window.localStorage;
		$curData=JSON.parse(ls.getItem("JSmertoListTab"));
		$.each($curData.list,function(i,item){
			if (item.a.indexOf("wisp://") == 0)
			{
				$('<li><a href="'+item.a+'">'+item.n+'</a></li>').appendTo("#nav ul");
			}else
			{
				$('<li data-url="'+item.a+'">'+item.n+'</li>').appendTo("#nav ul");
			}
			
		});
		$("#nav ul li").eq(request('de')).addClass("move");	
		
	}
	
	loadTabData( request('dataFile'));
	 //Tab 滚动手势
	$ulw=0;
	$depreWidth=0;
	$("#nav ul li").each(function(){
		
		if ($(this).hasClass("move"))
		{
			$depreWidth=$ulw;
		}
		$ulw+=parseInt($(this).width());
	});
	$("#nav ul").css("width",$ulw+5);
	var strX=strY=$strartM=0;
	$min=parseInt($("#nav").width()) -  $ulw;
	if ($min < 0)
	{
		
		if (($depreWidth * -1 ) < $min)
		{
			$("#nav ul").css("margin-left", $min);
		}else{	
			$("#nav ul").css("margin-left", $depreWidth*-1);
		}
		$("#nav").live("touchstart",function(event){
			if (event.touches.length == 1)
			{
				//event.preventDefault(); 
				strX = event.targetTouches[0].pageX ; 
				strY = event.targetTouches[0].pageY;
				$strartM= parseInt($("#nav ul").css("margin-left"));
			}
		})
		$("#nav").live("touchmove",function(event){
			if (event.touches.length == 1)
			{
				//event.preventDefault(); 
				curX = event.targetTouches[0].pageX; 
				$c= curX - strX;			
				$marginLeft=curX - strX + $strartM;	
				if ($marginLeft < $min)
				{
				   $marginLeft = $min;
				}
				if ($marginLeft > 0) $marginLeft = 0;
				$(this).find("ul").css("margin-left", $marginLeft);
			}
		})
	}
	$("#nav ul li[data-url]").live("tap click",function(event){
		event.preventDefault(); 
		if (!$(this).hasClass("move"))
		{
			globalAjax.abort();
			$("#nav ul li.move").removeClass("move");
			$(this).addClass("move");
			
			$(".fixedk").remove();
			
			$("#content").empty();
			$("#content").css("-webkit-transform","scale(1)");
			$("#content").data("transform",1);
			$("#content").css("margin-left",0)
			$("#content").css("margin-top",0)
			$URL=$(this).attr("data-url");
			loadTabData ($URL)
		}
		return false;
	});

	
	
	
//页面放大和滚动	   
   $("#contentBor").height($(window).height() - $("#nav").height());
   $("#content").css("width",$("#contentBor").width());
    $("#content").data("transform",1);
	var curscale=curwidth=1;
	var contentX=contentY=contentML=contentMT=0;
	var movestart=false;
	$("#content").bind("touchstart",function(event){
	  if ( event.touches.length == 2 )
	   {
		 curscale=$("#content").data("transform");
		 if (curscale == undefined){ curscale=1;}
	   }else if ( event.touches.length == 1)
	   {
			movestart=true;
			contentX=event.targetTouches[0].pageX;
			contentY=event.targetTouches[0].pageY;
			contentML=parseInt($("#content").css("margin-left"));
			contentMT=parseInt($("#content").css("margin-top"));
	   }
	});
	$("#content").bind("touchmove",function(event){
		event.preventDefault(); 
		if ( event.touches.length == 2 )
		{
			scaleval=event.scale *curscale;
			if (scaleval >3)scaleval=3;
			if (scaleval <1)scaleval=1;
			$("#content").css("-webkit-transform","scale("+scaleval +")");
			$("#content").data("transform",scaleval);
			marginmax= ($("#content").width() - $("#contentBor").width())/2; 
			$marginLeft = parseInt($("#content").css("margin-left"));
			if ( Math.abs($marginLeft) >= marginmax )
			{
				$("#content").css("margin-left", marginmax* ($marginLeft/Math.abs($marginLeft)));
			}
			$marginTop = parseInt($("#content").css("margin-top"));
			marginmaxH=$("#content").height()/2 - ($("#content").height()/2/$("#content").data("transform"));
			marginminH= ($("#content").height() - $("#contentBor").height() -marginmaxH)*-1;
			if ($marginTop <marginminH )$marginTop=marginminH;
			if ($marginTop > marginmaxH)$marginTop=marginmaxH;
			$("#content").css("margin-top", $marginTop);
		
		}else if (event.touches.length == 1)
		{
			if (movestart)
			{
				curX = event.targetTouches[0].pageX; 
				curY = event.targetTouches[0].pageY; 
				$marginLeft=curX - contentX + contentML;
				$marginTop=curY - contentY + contentMT;	
				marginmax= ($("#content").width() - $("#contentBor").width())/2; 
				 if ( Math.abs($marginLeft) < marginmax )
				 {
					 $("#content").css("margin-left", $marginLeft);
				 }
				marginmaxH=$("#content").height()/2 - ($("#content").height()/2/$("#content").data("transform"));
				marginminH= ($("#content").height() - $("#contentBor").height() -marginmaxH)*-1;
			
				if ($marginTop <marginminH )$marginTop=marginminH;
				if ($marginTop > marginmaxH)$marginTop=marginmaxH;
				$("#content").css("margin-top", $marginTop);
			}else
			{
				movestart=true;
				contentX=event.targetTouches[0].pageX;
				contentY=event.targetTouches[0].pageY;
				contentML=parseInt($("#content").css("margin-left"));
				contentMT=parseInt($("#content").css("margin-top"));
			}
		}
	});
	$("#content").bind("touchend",function(event){
		if(event.touches.length)
		{
			movestart=false;
		}
	});
 //缩放

	
	
 $(".multipleimgBox span").live("tap click",function(){
  		$(".tan").show();
  });
  $(".tan ul li").live("tap click",function(){
  		img=$(this).data('img');
		$(".tan").hide();
		$(".multipleimg img").hide();
		 $("#loading").show();
		$(".multipleimgBox span").text($(this).text());
		$("<img src='"+img+"'/>").bind("load",function(){
				$(".multipleimg img").attr("src",img).show();
				 $("#loading").hide();
		});
  });
 
 
 
})
function loadTabData ($URL){
	if ($URL.indexOf("http://") == 0 || $URL.indexOf("./") == 0 || $URL.indexOf("/") == 0)
	{
	globalAjax=$.ajax({
			  url: $URL+"?a="+Math.random(),
			  cache: false,
			  type : "GET",
			  async :true,
			  dataType  : "json",
			  success: function(data){
				if (data.length == 0)return false;  
				html = template.render(data.type,data);
				$("#content").html(html);
				if (data.type == "singleimg")
				{
					$('<div class="fixedk singleimgtime"><span>'+data.c2+'</span></div>').appendTo("#contentBor");
				}else if (data.type == "multipleimg")
				{
					$('<div class="fixedk multipleimgBox"><span>'+data.imgs[0].n+'</span></div>').appendTo("#contentBor");
					$tan=$("<div class='fixedk tan'><ul></ul></div>");
					$.each(data.imgs,function(i,item){
						$("<li>"+item.n+"</li>").data("img",item.i).appendTo($tan.find("ul"));
					});
					$tan.appendTo("body");
				}else if (data.type == "alarm")
				{
					
					var jsbg={"minx":"117.146727","miny":"30.931664","maxx":"122.239379","maxy":"33.724338"};
					var jsxy={"南京市":{"x":"118.796877","y":"32.060255"},"镇江市":{"x":"119.425836","y":"32.187849"},"常州市":{"x":"119.974454","y":"31.810077"},"无锡市":{"x":"120.311143","y":"31.490637"},"苏州市":{"x":"120.585316","y":"31.298886"},"扬州市":{"x":"119.412966","y":"32.394210"}};
					var wjsbgwidth=$(".alarmimg > img").width();
					var wjsbgheight = $(".alarmimg > img").height();
					var wjbgkdw=Math.abs(jsbg.maxx - jsbg.minx);
					var wjbgkdh=Math.abs(jsbg.maxy - jsbg.miny);
					
					$.each(data.l,function(i,item){
									
						if (item.a2 == "" || item.a2 == item.a1)
						{
							yjcityx=eval("jsxy."+item.a1+".x");
							yjcityy=eval("jsxy."+item.a1+".y");
							posleft = ((jsbg.maxx - yjcityx)/wjbgkdw )*wjsbgwidth;
							postop = ((jsbg.maxy - yjcityy)/wjbgkdh )*wjsbgheight;
							posleft = posleft > wjsbgwidth ?wjsbgwidth:posleft;
							postop = postop > wjsbgheight ?wjsbgheight:postop;
							$("<div class='alarmicon'><img src='http://www.weather.com.cn/m/i/alarm_s/"+item.a8+".gif'/></div>").css({"left":posleft,"top":postop}).appendTo(".alarmimg");
						}
					});	
				}

			  }
		});
	}else
	{
		$("#content").html('<p>'+$URL+'</p>');
		$("#loading").hide();
	}
}
