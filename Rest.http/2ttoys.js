function initPrices(){

    var prices=[
    {id:'',prc:0,code:'',taxid:'',canbuy:false}
                        ,{id:'P7885', prc:224.99, code:'P7885~224.990000~-1.000~-1.000~-1.000~0~0.000~~~LEGO 42054 Tractor met veel functies~0.00~2TTOYS LEGO NL~2TTOYS LEGO NL~GEEN KORTING~12 +~LEGOÂ®|LEGO Technic|~~~0.000000~0.000~~0~~/', taxid:'',canbuy:true}
                    ];

    for(var n=0,num=prices.length;n<num;n++)
    {
        var p=prices[n],el=gl('ProductPrice-'+p['id']);
        if(el)
        {
            tf.core.regPrc([p['code']]);
            var pp=tf.wm.pProp(p['id']);

            if($('[name=ProductPriceLayout]').length>0)
            {
                tf.core.ppriceTemplateLayout(el,[p['id'],'',p['taxid']]);
                var el=gl('ProductBasePrice-'+p['id']);if(el)el.innerHTML=tf.core.bprice([p['id'],pp[18],pp[19],pp[20]]);
            } else {
                var ret=tf.core.pprice(el, [p['id'],'',p['taxid']]);
                if(ret)el.innerHTML=ret;
            }

        }
    }
}
initPrices()