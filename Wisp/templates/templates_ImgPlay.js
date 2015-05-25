var GolobalTimeout;
var PageData;
var ProTile;
var ImgVisible; 
var ImgText;
var Progress;
var ST=window.sessionStorage;
$(function(){
	 ProTile=$("#slideshow #title");
	 ImgVisible=$("#slideshow a"); 
	 ImgText=$(".text");
	 Progress=$("#progress");
	$("#playbutton").bind("tap click",function(){
		if($(this).hasClass("zting"))
		{
			$(this).removeClass("zting").addClass("playing");
			try{clearTimeout(GolobalTimeout)}catch(e){};
			if (parseInt(ST.getItem("CurCount")) == PageData.list.length-1)
			{
				ST.setItem("CurCount",-1);
		    }
			Play();
		}else if ($(this).hasClass("playing"))
		{
			$(this).removeClass("playing").addClass("zting");	
		}
	});
	
	init();
	function init(){
			windowsWidth= parseInt($(window).width());		
			$("#slideshow").width(windowsWidth*1);
			$(".play").width(windowsWidth*1);
			$.ajax({
				 url:getDataFile(),
				 dataType:"text",
				 cache:false,
				 success:function(str){
					    if (str.indexOf("ImageData(")==0)
						{
								str= str.replace("ImageData(","");
							    str= str.replace(/\)$/,"");
						}
					    eval("data="+str);
						PageData=data;
						ProTile.html(PageData.title);
						DefaultShow = PageData.show == 'first' ? 0 : PageData.show;
						DefaultShow = DefaultShow == 'last' ? PageData.list.length -1 : DefaultShow;
						DefaultShow =  parseInt(DefaultShow);
						ImgText.empty();
						$.each(PageData.list,function(i,item){
							$("<span>"+item.name+"</span>").appendTo(ImgText);
						});
						ImgText.find("span").bind("tap click",function(event){
							SwitchImg(ImgText.find("span").index(this));
						});
						SwitchImg(DefaultShow);
				 }
			 });
			
	}
	function getDataFile(){
		return request('dataFile');
	}
	function SwitchImg(count){
		ProgrssWidth=count/PageData.list.length*100+'%';
		Progress.find("#progressfill").animate({"width":ProgrssWidth},100);
		$(document).trigger('ajaxStart');
		$('<img src="'+ PageData.list[count].url +'"/>').bind("load",function(){
			ImgVisible.attr("href",PageData.list[count].aurl);
			ImgVisible.find('img').attr("src",PageData.list[count].url).show();
			$(document).trigger('ajaxSuccess');
			ImgText.find("span").removeClass("se").eq(count).addClass("se");
			ST.setItem("CurCount",count);
		});
	}
	
})
function Play(){
	pre=parseInt(ST.getItem("CurCount"));
	if ((pre+1) < PageData.list.length )
	{
		count=pre+1;
		ProgrssWidth=count/(PageData.list.length-1)*100+'%';
		Progress.find("#progressfill").animate({"width":ProgrssWidth},100);
		$(document).trigger('ajaxStart');
		$('<img src="'+ PageData.list[count].url +'"/>').bind("load",function(){
			ImgVisible.attr("href",PageData.list[count].aurl);
			ImgVisible.find('img').attr("src",PageData.list[count].url);
			$(document).trigger('ajaxComplete');
			ImgText.find("span").removeClass("se").eq(count).addClass("se");
			ST.setItem("CurCount",count);				
			GolobalTimeout=setTimeout("Play()",3000);
		});
	}else
	{
		try{clearTimeout(GolobalTimeout)}catch(e){}
		$("#playbutton").removeClass("playing").addClass("zting");	
	}

}