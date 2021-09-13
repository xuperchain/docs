function navInit() {
    // pc
    if ($(document).scrollTop() < $("#quicken").offset().top) {
        $(".hov p").removeAttr("style", "");
        $(".hov p a").removeAttr("style", "");
        $("p.hovm1").css('border-left', '1px solid #01D8CC');
        $("p.hovm1 a").css('color', '#08C3C8');
    } else if ($(document).scrollTop() < $("#techintro").offset().top) {
        $(".hov p").removeAttr("style", "");
        $(".hov p a").removeAttr("style", "");
        $("p.hovm2").css('border-left', '1px solid #01D8CC');
        $("p.hovm2 a").css('color', '#08C3C8');
    }
    else if ($(document).scrollTop() < $("#application").offset().top) {
        $(".hov p").removeAttr("style", "");
        $(".hov p a").removeAttr("style", "");
        $("p.hovm3").css('border-left', '1px solid #01D8CC');
        $("p.hovm3 a").css('color', '#08C3C8');
    } else if ($(document).scrollTop() < $("#ecology").offset().top) {
        $(".hov p").removeAttr("style", "");
        $(".hov p a").removeAttr("style", "");
        $("p.hovm4").css('border-left', '1px solid #01D8CC');
        $("p.hovm4 a").css('color', '#08C3C8');

    } else {
        $(".hov p").removeAttr("style", "");
        $(".hov p a").removeAttr("style", "");
        $("p.hovm5").css('border-left', '1px solid #01D8CC');
        $("p.hovm5 a").css('color', '#08C3C8');
    }
    // phone
    if ($(document).scrollTop() > $('.wy-nav-top').height()) {
        $('.hov2').css('position', 'fixed');
        $('.hov2').css('top', 0);
        $('.hov2').css('width', '100%');
    } else {
        $('.hov2').css('position', 'relative');
        $('.hov2').css('top', 0);
        $('.hov2').css('width', 'auto');
    }
    if ($(document).scrollTop() < $("#quicken").offset().top) {
        $(".hov2 p a").removeAttr("style", "");
        $("a.hovm6").css('border-bottom', '2px solid #333333');
        $("a.hovm6").css('font-weight', '500');
        $(".hovm").scrollLeft(0);
    } else if ($(document).scrollTop() < $("#techintro").offset().top) {
        $(".hov2 p a").removeAttr("style", "");
        $("a.hovm7").css('border-bottom', '2px solid #333333');
        $("a.hovm7").css('font-weight', '500');
        $(".hovm").scrollLeft(0);
    }
    else if ($(document).scrollTop() < $("#application").offset().top) {
        $(".hov2 p a").removeAttr("style", "");
        $("a.hovm8").css('border-bottom', '2px solid #333333');
        $("a.hovm8").css('font-weight', '500');
        $(".hovm").scrollLeft(0);
    } else if ($(document).scrollTop() < $("#ecology").offset().top) {
        $(".hov2 p a").removeAttr("style", "");
        $("a.hovm9").css('border-bottom', '2px solid #333333');
        $("a.hovm9").css('font-weight', '500');
        $(".hovm").scrollLeft(76);
    } else {
        $(".hov2 p a").removeAttr("style", "");
        $("a.hovm10").css('border-bottom', '2px solid #333333');
        $("a.hovm10").css('font-weight', '500');
        $(".hovm").scrollLeft($('.hovm').width());
    }
}
window.onload = function()
{
    // pc
    $(".hov p").removeAttr("style", "");
    $(".hov p a").removeAttr("style", "");
    $("p.hovm1").css('border-left', '1px solid #01D8CC');
    $("p.hovm1 a").css('color', '#08C3C8');
    // phone
    $(".hov2 p a").removeAttr("style", "");
    $("a.hovm6").css('border-bottom', '2px solid #333333');
    $("a.hovm6").css('font-weight', '500');
    $("p.caption").click(function(){
        $(this).next("ul").find("li.toctree-l1").slideToggle("slow");
        if ($(this).hasClass('active')) {
            $(this).removeClass('active');
        } else {
            $(this).addClass('active');
        }
    });
    $('.hide').click(function(){
        var value = $('.wy-side-nav-search input').val();
        if (value.length < 1){
            console.log("no")
        }else{ 
            window.location.href = 'search.html?' + 'q=' + value + '&check_keywords=yes&area=default';        
        }
    });
    $(document).scroll(function () {
        navInit();
    });
}
