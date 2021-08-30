console.log("##############")
$("p.caption").click(function(){
    $(this).next("ul").find("li.toctree-l1").slideToggle("slow")
})