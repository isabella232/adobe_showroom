window.addEventListener("message", function (event) {
    if (event.data.action == "display") {
        $(".rusure").fadeOut();
        $(".slidewrap .slidelist > li").html("")
        vehindex = 1
        maxvehindex = 0
        $(".slidewrap .slidelist > li").css('transform', 'translateX(695px)');
        nowselected = 1
        keylocked = true
        setTimeout(() => {
            SelectVehicle()
        }, 1000)
        setTimeout(() => {
            $(".ui").fadeIn();
        }, 2000);
        keylocked = false
    }
    else if (event.data.action == "hide") {
        $(".ui").fadeOut();
    }
    else if (event.data.action == "setvehicle") {
        nowselected = 1
        if (event.data.place == "garage") {
            $(".placeimg").attr("src", "img/icon/garage.png")
            $(".placetext").text('차고')
        }
        if (event.data.place == "showroom") {
            $(".placeimg").attr("src", "img/icon/showroom.png")
            $('.placetext').text('쇼룸')
        }
        nowtype = event.data.place
        SetVehicle(event.data.veh)
    }
    else if (event.data.action == "setvehiclespec") {
        specinfo.forEach(info => {
            eval(info + '=' + eval('event.data.' + info))
        });
    }
    else if (event.data.action == "garagemenu") {
        nowtype = ''
        $(".ui2").fadeIn()
        
    }
})
function comma(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
var maxvehindex = 0;
var nowtype
var vehinfo = ["name", "maker", "class", "price", "code"]
var vehindex = 1;
function SetVehicle(veh) {
    maxvehindex = maxvehindex + veh.length
    $(".slidewrap .slidelist > li").html("")
    setTimeout(() => {
        veh.forEach(element => {
            $(".slidewrap .slidelist > li").append(
                '<div class="vehicleboxmargin">\
                <div class="vehiclebox" id="vehiclebox'+ vehindex + '">\
                    <div class="vehicleb">\
                        <img src="img/'+ element.maker + '.png" class="makerpic_small">\
                        <div class="vehiclenamebox">\
                            <div class="vehiclename">'+ element.name + '</div>\
                            <div class="makername">'+ element.maker + '</div>\
                        </div>\
                        <div class="vehicleclassbox">\
                            <div class="vehicleclass">'+ element.class + '</div>\
                        </div>\
                        <div class="vehicleprice">'+ comma(element.price) + '원</div>\
                    </div>\
                </div>\
            </div>')
            vehinfo.forEach(info => {
                $('#vehiclebox' + vehindex).data(info, eval('element.' + info))
            });
            vehindex = vehindex + 1
        });

    }, 500);
}

function SelectVehicle() {
    $('.vehicleclassinbox').text($('#vehiclebox' + nowselected).data('class'))
    $.post("http://adobe_showroom/SelectVehicle", JSON.stringify({ code: $('#vehiclebox' + nowselected).data('code') }));
    setTimeout(() => {
        $('.vehicleclassinbox').text($('#vehiclebox' + nowselected).data('class'))
        $('.makerpic_big').attr('src', 'img/' + $('#vehiclebox' + nowselected).data('maker') + '.png')
        if (nowtype == 'showroom') {
            $('.price').text(comma($('#vehiclebox' + nowselected).data('price')) + '원')   
        }
        else {
            $('.price').text('꺼내기')
        }
        $('#maxspeed').val(Math.round(maxspeed * 3.6))
        $('#handling').val(Math.round(handling * 10))
        $('#brake').val(Math.round(brake * 10))
        $('#seats').text(seats + 1)
        $('#fuel').text(fuel)
        $('#maxspeed_spec').text(Math.round((maxspeed * 3.6) * 100) / 100)
        $('#handling_spec').text(Math.round(handling * 100) / 100)
        $('#brake_spec').text(Math.round(brake * 100) / 100)
    }, 300);

}

var specinfo = ['maxspeed', 'brake', 'seats', 'handling', 'fuel']
var maxspeed
var brake
var seats
var handling
var fuel

var keylocked = false
var nowselected = 1
$(document).ready(function () {
    $('.buybox').click(function () {
        if (nowtype == 'showroom') {
            $('.rusure').fadeIn();
            $('#rusure_yes').click(function() {
                $.post("http://adobe_showroom/BuyVehicle", JSON.stringify({ price: $('#vehiclebox' + nowselected).data('price'), code: $('#vehiclebox' + nowselected).data('code'), name: $('#vehiclebox' + nowselected).data('name') }));
            })
            $('#rusure_no').click(function() {
                $('.rusure').fadeOut();
            })   
        }
        if (nowtype == 'garage') {
            $.post("http://adobe_showroom/TakeVehicle", JSON.stringify({ code: $('#vehiclebox' + nowselected).data('code'), name: $('#vehiclebox' + nowselected).data('name'), maker: $('#vehiclebox' + nowselected).data('maker') }));
        }
    })
    $('.front').click(function () {
        $.post("http://adobe_showroom/Front", JSON.stringify({}));
    })
    $('.back').click(function () {
        $.post("http://adobe_showroom/Back", JSON.stringify({}));
    })
    $('.pov').click(function () {
        $.post("http://adobe_showroom/Pov", JSON.stringify({}));
    })
    $('#garage_button').click(function () {
        $.post("http://adobe_showroom/opengarage", JSON.stringify({}));
        $(".ui2").fadeOut()
    })
    $('#back_button').click(function () {
        $.post("http://adobe_showroom/back", JSON.stringify({}));
        $(".ui2").fadeOut()
    })
    var paperwidth = 270
    $("body").on("keyup", function (key) {
        if (65 == key.which) { //a
            if (keylocked == false) {
                if (nowselected == 1) {
                    nowselected = maxvehindex
                    $(".slidewrap .slidelist > li").css('transform', 'translateX(' + parseInt(parseInt($('.slidewrap .slidelist > li').css('transform').split(',')[4]) - paperwidth * (maxvehindex - 1)) + 'px)');
                    SelectVehicle()
                    keylocked = true
                    setTimeout(function () {
                        keylocked = false
                    }, 500)
                }
                else {
                    nowselected = nowselected - 1
                    $(".slidewrap .slidelist > li").css('transform', 'translateX(' + parseInt(parseInt($('.slidewrap .slidelist > li').css('transform').split(',')[4]) + paperwidth) + 'px)');
                    SelectVehicle()
                    keylocked = true
                    setTimeout(function () {
                        keylocked = false
                    }, 500)
                }
            }
        }
        else if (68 == key.which) { //d 
            if (keylocked == false) {
                if (nowselected == maxvehindex) {
                    nowselected = 1
                    $(".slidewrap .slidelist > li").css('transform', 'translateX(695px)');
                    SelectVehicle()
                    keylocked = true
                    setTimeout(function () {
                        keylocked = false
                    }, 500)
                }
                else {
                    nowselected = nowselected + 1
                    $(".slidewrap .slidelist > li").css('transform', 'translateX(' + parseInt(parseInt($('.slidewrap .slidelist > li').css('transform').split(',')[4]) - paperwidth) + 'px)');
                    SelectVehicle()
                    keylocked = true
                    setTimeout(function () {
                        keylocked = false
                    }, 500)
                }
            }
        }
        else if (27 == key.which) {
            if (keylocked == false) {
                $.post("http://adobe_showroom/NUIFocusOff", JSON.stringify({ asdf: nowtype}));
                $(".ui").fadeOut();
                $(".ui2").fadeOut()
            }
        }
    });
});