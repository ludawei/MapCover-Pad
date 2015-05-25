// JavaScript Document
	var globalAjax;
$(function(){

	
		   
	if (window.localStorage)
	{
		ls=window.localStorage;
		
		$curData=JSON.parse(ls.getItem("JSTabcurData"));
	}
	$de=parseInt($curData.de);

	$defaultURL=$curData.tab[$de].data;
	
	
	$.each($curData.tab,function(i,item){
		if (item.data.indexOf("wisp://") == 0)
		{
			$('<li><a href="'+item.data+'">'+item.name+'</a></li>').appendTo("#nav ul");
		}else
		{
			$('<li data-url="'+item.data+'">'+item.name+'</li>').appendTo("#nav ul");
		}
	});
	$("#nav ul li").eq($de).addClass("move");		   
	//先异步加载默认的HTML页面	   
	loadTabData ($defaultURL);

		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   

	//Tab 滚动手势
	$ulw=0;
	$("#nav ul li").each(function(){
		$ulw+=parseInt($(this).width());
	});
	$("#nav ul").css("width",$ulw+5);
	var strX=strY=$strartM=0;
	$min=parseInt($("#nav").width()) -  $ulw;
	if ($min < 0)
	{
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
	$(".leveltableyiji").live("tap click",function (){
			$(".leveltableerji").hide();
			$index=$(".leveltableyiji").index(this);
			$(".leveltableerji[data-erjiindex='"+$index+"']").show();
			
	})
	
	//		   
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
				marginmaxH= $("#content").height()/2 - ($("#content").height()/2/$("#content").data("transform"));
				marginminH= ($("#content").height() - $("#contentBor").height() -marginmaxH)*-1;
			
				if ($marginTop < marginminH )$marginTop=marginminH;
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
						$('<div class="fixedk singleimgtime"><span>'+data.c2+'</span></div>').css("left","5px").appendTo("#contentBor");
					}else if (data.type == "multipleimg")
					{
						$('<div class="fixedk multipleimgBox"><span>'+data.imgs[0].n+'<img src="./templates_dsyoujiao.png" /></span></div>').bind("tap click",                          function(){
								$(".tan").show();																										                        }).appendTo("#contentBor");
						$tan=$("<div class='fixedk tan'><ul></ul></div>").css("left","5px");
						$.each(data.imgs,function(i,item){
							$("<li>"+item.n+"</li>").data("img",item.i).appendTo($tan.find("ul"));
						});
						$tan.appendTo("body");
						 $(".tan ul li").unbind("tap click");
						 $(".tan ul li").bind("tap click",function(){
								img=$(this).data('img');
								$(".tan").hide();
								$(".multipleimg img").hide();
								 $("#loading").show();
								$(".multipleimgBox span").html($(this).text()+'<img src="./templates_dsyoujiao.png" />');
								$("<img src='"+img+"'/>").bind("load",function(){
										$(".multipleimg img").attr("src",img).show();
										 $("#loading").hide();
								});
						  });
						
					}else if (data.type == "alarm")
					{
					 var jsxy={"南京市":{"x":"42%","y":"67%"},"镇江市":{"x":"53%","y":"67%"},"常州市":{"x":"55%","y":"75%"},"无锡市":{"x":"67%","y":"73%"},"苏州市":{"x":"70%","y":"84%"},"扬州市":{"x":"54%","y":"49%"},"盐城市":{"x":"62%","y":"30%"},"徐州市":{"x":"20%","y":"20%"},"淮安市":{"x":"47%","y":"35%"},"连云港市":{"x":"47%","y":"12%"},"南通市":{"x":"71%","y":"56%"},"泰州":{"x":"62%","y":"49%"},"宿迁":{"x":"36%","y":"35%"}};
					 $('<img  src="templates_dsJSAlarmbg.png" />').bind("load",function(){
					    $(this).appendTo(".alarm .alarmimg");
						$.each(data.l,function(i,item){
							if (item.a2 == "" || item.a2 == item.a1)
							{
								yjcityx=eval("jsxy."+item.a1+".x");
								yjcityy=eval("jsxy."+item.a1+".y");
								$("<div class='alarmicon'><img style='width:20px;height:17px;' src='http://www.weather.com.cn/m/i/alarm_s/"+item.a8+".gif'/></div>").css({"left":yjcityx,"top":yjcityy}).appendTo(".alarmimg");
							}
						});
					  
					  });
						
						
						
					}else if (data.type == "szyb")
					{
						
						
						var wdData=[],jsData=[];
						for (i=0;i<data.d.length;i++)
						{
							wdData.push([data.d[i].p * 1000,data.d[i].c]);
							jsData.push([data.d[i].p * 1000,data.d[i].m]);
						}
						var options={ 
								   xaxis:{mode: 'time',show:true, timeformat: '%d日%h时',tickSize:[12,"hour"]},
								   yaxes: [ {tickDecimals:0},
											{
											  alignTicksWithAxis: 1,
											  position: 'right',
											  tickDecimals:0
											}],
								   grid: { hoverable: true, clickable: true },
								   legend: { container: $("#lengedg") ,noColumns: 2}
					   	  		};
						var plotdata=[{data:wdData,label: "气温/℃",yaxis:1,lines:{show:true},points: {show:true }},
								     {data:jsData,label: "降水量/mm",yaxis:2,lines:{show:true}, points: {show:true}}];
					   Plot=$.plot($("#placeholder"),plotdata,options);
					    $("#placeholder").live("plothover", function (event, pos, item) {
						   if (item) {
								if (previousPoint != item.dataIndex || previousSeries != item.seriesIndex ) {
									previousPoint = item.dataIndex;
									previousSeries = item.seriesIndex;
									$("#tooltip").remove();
									var x = item.series.xaxis.ticks[previousPoint].label,
										y = item.datapoint[1];
									contents=item.series.label.replace("/℃","").replace("/mm","");
									contents+=':'+x+' ' +y;
									$('<div id="tooltip">' + contents + '</div>').css( {
										position: 'absolute',
										display: 'block',
										top:item.pageY + 5,
										left: item.pageX + 5,
										border: '1px solid #fdd',
										padding: '2px',
										'width':'auto',
										'background-color': '#fee',
										opacity: 0
									}).appendTo("body").animate({opacity: 0.80},200);
								}
							}
							else {
								$("#tooltip").remove();
								previousPoint = null;            
							}
						});
					    $('<div class="fixedk multipleimgBox"><span>'+data.n+'<img src="./templates_dsyoujiao.png" /></span></div>').css("right","5px").bind("tap click",                          function(){
								$(".tan").show();																										                        }).appendTo("#contentBor");
						$tan=$("<div class='fixedk tan'><ul><li data-href='101190101'>南京</li><li data-href='101190201'>无锡</li><li data-href='101190301'>镇江</li><li data-href='101190401'>苏州</li><li data-href='101190501'>南通</li><li data-href='101190601'>扬州</li><li data-href='101190701'>盐城</li><li data-href='101190801'>徐州</li><li data-href='101190901'>淮安</li><li data-href='101191001'>连云港</li><li data-href='101191101'>常州</li><li data-href='101191201'>泰州</li><li data-href='101191301'>宿迁</li></ul></div>");
					    $tan.appendTo("body");
						 $(".tan ul li").unbind("tap click");
						 $(".tan ul li").bind("tap click",function(event){
								$(".tan").hide();
								$areaid=$(this).attr("data-href");
								$url=$URL.replace(new RegExp("[\\d]{9}","g"), $areaid);
								globalAjax=$.ajax({
									  url: $url+"?a="+Math.random(),
									  cache: false,
									  type : "GET",
									  async :true,
									  dataType  : "json",
									  success: function(data){
										  $(".multipleimgBox span").html(data.n+'<img src="./templates_dsyoujiao.png" />');
										  	$("#content").css("-webkit-transform","scale(1)");
											$("#content").data("transform",1);
											$("#content").css("margin-left",0)
											$("#content").css("margin-top",0)
									  		var wdData=[],jsData=[];
											for (i=0;i<data.d.length;i++)
											{
												wdData.push([data.d[i].p * 1000,data.d[i].c]);
												jsData.push([data.d[i].p * 1000,data.d[i].m]);
											}
										 plotdata=[{data:wdData,label: "气温/℃",yaxis:1,lines:{show:true},points: {show:true }},
								         {data:jsData,label: "降水量/mm",yaxis:2,lines:{show:true}, points: {show:true}}];
					   					$("#placeholder").remove();
									   $('<div id="placeholder" style="width:100%;height:150px;"></div>').appendTo(".szyb");
										$.plot($("#placeholder"),plotdata,options);
									  }
								});
								event.stopPropagation();
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
