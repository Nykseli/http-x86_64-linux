
console.log("hello from asm!");
var speed = 10,
    d = 1,
    di = 1;
    hov = 0;

window.onload = function(){
    box = document.getElementById('box');
    mtop = box.offsetTop;
    mleft = box.offsetLeft;
    mbottom = mtop + 150;
    mright = mleft + 150;
    i = setInterval(function () {
        cw = box.offsetLeft;
        ch = box.offsetTop;
        if(d == 1){
            if(cw > mright){
                hov = 1;
                di = 1
                d = 2;
            }
        }
        if(d == 2){
            if(ch > mbottom){
                hov = 0;
                di = -1
                d = 3;
            }
        }
        if(d == 3){
            if(cw < mleft){
                hov = 1;
                di = -1
                d = 4;
            }
        }
        if(d == 4){
            if(ch < mtop){
                hov = 0;
                di = 1
                d = 1;
            }
        }

        if(hov)
            box.style.top = (ch + speed * di) + 'px';
        else
            box.style.left = (cw + speed * di) + 'px';
    },100);
}
