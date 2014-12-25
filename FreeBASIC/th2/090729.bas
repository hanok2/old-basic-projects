#include "fbgfx.bi"
declare sub drawtile (tile() as ubyte, x as double, y as double, w as double, h as double, d as integer)
declare sub loadimage (file as string, b as integer, tile() as ubyte)
declare sub loadmap (file as string)
declare sub loadgmap (file as string)
declare sub redraw (x as integer, y as integer)
type spobject
    x as double
    y as double
    sx as double
    sy as double
    d as integer
    st as integer
    cy as integer
    ac as double
    da as double
    ma as integer
    jmp as integer
    hlt as integer
    hur as integer
    lf as integer
end type
type object
    x as double
    y as double
    sx as double
    sy as double
    d as integer
    cy as integer
    st as integer
end type
type image
    i(16,16,3) as ubyte
end type

dim as spobject char
redim as object snake(1)
dim as object frisbee(5)
dim shared as image floor1, floor2, ladder, char1, char2, char3, char4, snake1, snake2
dim shared as image snake3, floor3, floor4, bg1, bg2, floor5, rocks, lava, disc1, disc2
dim shared as image pizza, coin
dim as integer sw, sh, x, y, snkcou, x1, y1, ful, cycle, wlk, spcbf, score, curmap, gx, gy
dim shared as ubyte map(20,15), colmap(20,15), gmap(100,100)
dim shared as double scw, sch, old
dim as string binn
const grav=0.2
boot:
open "config.ini" for input as 1
if eof(1) then
    close 1
    open "config.ini" for output as 1
    print #1,"# Treasure Hunt 2 config file"
    print #1,"# Do not edit this file if you don't know what you're doing"
    print #1,"# --------------"
    print #1,"# Treasure Hunt 2 (c) 2009 Electrokinesis Studios"
    print #1,"# --------------"
    print #1,"# Screen resolution"
    print #1,"res=640x480"
    print #1,"# Toggle fullscreen"
    print #1,"ful=0"
    close 1
    goto boot
endif
do until left(binn,4)="res=":input #1, binn:loop
for x=5 to len(binn)
    if mid(binn,x,1)="x" then y=x
next x
sw=val(mid(binn,5,y-5))
sh=val(mid(binn,y+1,len(binn)-y+1))
do until left(binn,4)="ful=":input #1, binn:loop
ful=val(mid(binn,5,len(binn)-4))
close 1
if ful<0 or ful>1 then ful=0
screenres sw,sh,16,,4+ful
windowtitle "Treasure Hunt 2"
scw = sw/320
sch = sh/240

loadimage ".\data\gfx\char.abn",0,char1.i()
loadimage ".\data\gfx\char.abn",1,char2.i()
loadimage ".\data\gfx\char.abn",2,char3.i()
loadimage ".\data\gfx\char.abn",3,char4.i()
loadimage ".\data\gfx\char.abn",4,disc1.i()
loadimage ".\data\gfx\char.abn",5,disc2.i()
loadimage ".\data\gfx\snake.abn",0,snake1.i()
loadimage ".\data\gfx\snake.abn",1,snake2.i()
loadimage ".\data\gfx\snake.abn",2,snake3.i()
loadimage ".\data\gfx\tiles.abn",0,floor1.i()
loadimage ".\data\gfx\tiles.abn",1,floor2.i()
loadimage ".\data\gfx\tiles.abn",2,ladder.i()
loadimage ".\data\gfx\tiles.abn",3,floor3.i()
loadimage ".\data\gfx\tiles.abn",4,floor4.i()
loadimage ".\data\gfx\tiles.abn",5,bg1.i()
loadimage ".\data\gfx\tiles.abn",6,bg2.i()
loadimage ".\data\gfx\tiles.abn",7,floor5.i()
loadimage ".\data\gfx\tiles.abn",8,rocks.i()
loadimage ".\data\gfx\tiles.abn",9,lava.i()
loadimage ".\data\gfx\tiles.abn",10,pizza.i()
loadimage ".\data\gfx\tiles.abn",11,coin.i()
loadgmap ".\data\gmap.abm"

char.lf=3
gmap(0,0)=1
curmap=gmap(gx,gy)
'char.x=16:char.y=16
char.ac=0.1:char.da=0.09:char.ma=2:char.jmp=3
loadup:
screenlock
loadmap ".\data\map"+str(curmap)+".abm"
char.d=1:char.hlt=10
char.sx=0:char.sy=0
for x1=0 to 4:frisbee(x1).st=0:next x1
'line (0,0)-(sw,sh),rgb(130,80,0),BF
redim snake(1)
snkcou = 0
for y = 0 to 14:for x = 0 to 19
    redraw x,y
    select case colmap(x,y)
    case 3:char.x=x*16:char.y=y*16
    case 4:snkcou+=1:redim preserve snake(snkcou) as object:snake(snkcou-1).x=x*16:snake(snkcou-1).y=y*16:snake(snkcou-1).d=1:snake(snkcou-1).st=1
    end select
next x:next y
redim preserve snake(1 to ubound(snake))
screenunlock

do
    screenlock
    'line ((fix(char.x/16)-2)*16*scw,(fix(char.y/16)-2)*16*sch)-((fix(char.x/16)+3)*16*scw-1,(fix(char.y/16)+4)*16*sch-1),rgb(130,80,0),BF
    'line ((fix(char.x/16)-2)*16*scw,fix(snake(snkcou).y/16)*16*sch)-((fix(char.x/16)+3)*16*scw-1,fix(snake(snkcou).y/16)*16*sch-1),rgb(130,80,0),BF
    for snkcou = lbound(snake) to ubound(snake):for x=fix(snake(snkcou).x/16) to fix(snake(snkcou).x/16)+1
        y = fix(snake(snkcou).y/16)
        if snake(snkcou).st=1 then redraw x,y
    next x:next snkcou
    for y=fix(char.y/16)-1 to fix(char.y/16)+3:for x=fix(char.x/16)-2 to fix(char.x/16)+2
        redraw x,y
    next x:next y
    for snkcou = 0 to 4:if frisbee(snkcou).st=1 then
        for y=fix(frisbee(snkcou).y/16) to fix(frisbee(snkcou).y/16)+1:for x=fix(frisbee(snkcou).x/16)-1 to fix(frisbee(snkcou).x/16)+1
        redraw x,y:next x:next y
    endif:next snkcou
    for snkcou = 0 to 4:if frisbee(snkcou).st=1 then
        select case frisbee(0).cy
        case 1:drawtile disc1.i(), frisbee(snkcou).x*scw, frisbee(snkcou).y*sch, scw, sch, 1
        case 2:drawtile disc2.i(), frisbee(snkcou).x*scw, frisbee(snkcou).y*sch, scw, sch, 1
        end select
    endif:next snkcou
    drawtile char1.i(), char.x*scw, char.y*sch, scw, sch, char.d
    select case char.cy
    case 1, 3:drawtile char2.i(), char.x*scw, (char.y+16)*sch, scw, sch, char.d
    case 2:drawtile char3.i(), char.x*scw, (char.y+16)*sch, scw, sch, char.d
    case 4:drawtile char4.i(), char.x*scw, (char.y+16)*sch, scw, sch, char.d
    case 5:drawtile char3.i(), char.x*scw, (char.y+16)*sch, scw, sch, char.d
    end select
    select case snake(0).cy
    case 1:for x = lbound(snake) to ubound(snake):if snake(x).st=1 then:drawtile snake1.i(), snake(x).x*scw, snake(x).y*sch, scw, sch, snake(x).d:endif:next x
    case 2, 4:for x = lbound(snake) to ubound(snake):if snake(x).st=1 then:drawtile snake2.i(), snake(x).x*scw, snake(x).y*sch, scw, sch, snake(x).d:endif:next x
    case 3:for x = lbound(snake) to ubound(snake):if snake(x).st=1 then:drawtile snake3.i(), snake(x).x*scw, snake(x).y*sch, scw, sch, snake(x).d:endif:next x
    end select
    locate 1,1
    print char.hlt, char.lf, char.hur, score
    screenunlock
    char.x+=char.sx:char.y+=char.sy
    if cycle<=0 then
        if wlk and char.st then
            char.cy+=1:if char.cy>=5 then char.cy=1
        endif
        snake(0).cy+=1:if snake(0).cy>=5 then snake(0).cy=1
        frisbee(0).cy+=1:if frisbee(0).cy>=3 then frisbee(0).cy=1
        if char.hur>0 then char.hur-=1
        select case char.d
        case 0: char.d=-1
        case 2: char.d=1
        end select
        cycle = 10
    endif
    for x = lbound(snake) to ubound(snake)
        if colmap(int((snake(x).x+8+snake(x).d*8)/16),int((snake(x).y+31)/16))=1 and colmap(int((snake(x).x+8+snake(x).d*8)/16),int((snake(x).y)/16))<>1 and colmap(int((snake(x).x+8+snake(x).d*8)/16),int((snake(x).y)/16))<>2 then:snake(x).x+=snake(x).d/2:else:snake(x).d*=-1:endif
        if char.x+15 >= snake(x).x and char.y+31 >= snake(x).y and char.x <= snake(x).x+15 and char.y <= snake(x).y+15 and char.hur=0 and snake(x).st=1 then
            if char.hlt-1 <= 0 then goto death
            char.hlt-=1:char.hur=10
        endif
    next x
    for snkcou = 0 to 4
        if frisbee(snkcou).st=1 then
            if colmap(int((frisbee(snkcou).x+8+frisbee(snkcou).d*8)/16),int((frisbee(snkcou).y+4)/16))=1 or colmap(int((frisbee(snkcou).x+8+frisbee(snkcou).d*8)/16),int((frisbee(snkcou).y+10)/16))=1 then
                frisbee(snkcou).st=0
                'for y=fix(frisbee(snkcou).y/16) to fix(frisbee(snkcou).y/16)+1:for x=fix(frisbee(snkcou).x/16)-1 to fix(frisbee(snkcou).x/16)
                'redraw x,y:next x:next y
                y=fix(frisbee(snkcou).y/16)
                for x=fix(frisbee(snkcou).x/16)-1 to fix(frisbee(snkcou).x/16)+1
                redraw x,y:redraw x,y+1:next x
            else
                frisbee(snkcou).x+=frisbee(snkcou).d*3
                for y = lbound(snake) to ubound(snake)
                    if snake(y).st=1 then:if frisbee(snkcou).x+15 >= snake(y).x and frisbee(snkcou).y+15 >= snake(y).y and frisbee(snkcou).x <= snake(y).x+15 and frisbee(snkcou).y <= snake(y).y+15 then
                            frisbee(snkcou).st=0:snake(y).st=0
                            for x1=fix(frisbee(snkcou).x/16)-1 to fix(frisbee(snkcou).x/16)+2
                                for y1=fix(frisbee(snkcou).y/16)-1 to fix(frisbee(snkcou).y/16)+1
                                    redraw x1,y1
                                next y1
                            next x1
                            score+=1
                    endif:endif
                next y
            endif
        endif
    next snkcou
    if char.sy < 0 then if colmap(int((char.x+2)/16),int(char.y/16))=1 or colmap(int((char.x+8)/16),int(char.y/16))=1 then char.sy=0:char.y=int(char.y/16+1)*16
    if char.sx > 0 then if colmap(int((char.x+16)/16),int(char.y/16))=1 or colmap(int((char.x+16)/16),int((char.y+16)/16))=1 then char.sx=0:char.x=int(char.x/16)*16
    if char.sx < 0 then if colmap(int(char.x/16),int(char.y/16))=1 or colmap(int(char.x/16),int((char.y+16)/16))=1 then char.sx=0:char.x=int(char.x/16+1)*16
    if char.sx<>0 or char.sy<>0 then if colmap(int((char.x+4)/16),int((char.y+32)/16))=1 or colmap(int((char.x+10)/16),int((char.y+32)/16))=1 then:char.sy=0:char.st=1:char.y=int(char.y/16)*16:else:char.st=0:endif
    if colmap(int((char.x+4)/16),int((char.y+32)/16))=2 or colmap(int((char.x+10)/16),int((char.y+32)/16))=2 then char.st=1
    if colmap(int((char.x+4)/16),int((char.y+32)/16))=5 or colmap(int((char.x+10)/16),int((char.y+32)/16))=5 then goto death
    if char.st = 0 then:char.sy+=grav:char.cy=5
        if char.sy<>0 then
            if char.sx > 0 then if colmap(int((char.x+16)/16),int((char.y+32)/16))=1 then char.sx=0:char.x=int(char.x/16)*16
            if char.sx < 0 then if colmap(int((char.x)/16),int((char.y+32)/16))=1 then char.sx=0:char.x=int(char.x/16+1)*16
        endif
    elseif wlk=0 then char.cy=1:endif
    select case colmap(fix(char.x/16),fix(char.y/16))
    case 6:colmap(fix(char.x/16),fix(char.y/16))=0:if char.hlt=10 then:char.lf+=1:else char.hlt+=1:endif
    case 7:colmap(fix(char.x/16),fix(char.y/16))=0:score+=10
    end select
    select case colmap(fix(char.x/16),fix(char.y/16)+1)
    case 6:colmap(fix(char.x/16),fix(char.y/16)+1)=0:if char.hlt=10 then:char.lf+=1:else char.hlt+=1:endif
    case 7:colmap(fix(char.x/16),fix(char.y/16)+1)=0:score+=10
    end select
    if not (multikey(fb.sc_up) or multikey(fb.sc_down)) then
        if colmap(int((char.x+4)/16),int((char.y+32)/16))=2 or colmap(int((char.x+10)/16),int((char.y+32)/16))=2 then char.sy=0
        wlk=0
    endif
    if not (multikey(fb.sc_left) or multikey(fb.sc_right)) then
        if char.sx>0 then char.sx-=char.da:if char.sx < char.da then char.sx = 0
        if char.sx<0 then char.sx+=char.da:if char.sx > -char.da then char.sx = 0
        wlk=0
    endif
    if multikey(fb.sc_up) then
        if colmap(int((char.x+4)/16),int((char.y+30)/16))=2 or colmap(int((char.x+10)/16),int((char.y+30)/16))=2 then:char.sy=-1:wlk=1
        elseif char.st=1 then:char.sy=-char.jmp: char.st=0
        endif:endif
    if multikey(fb.sc_down) then if colmap(int((char.x+4)/16),int((char.y+32)/16))=2 or colmap(int((char.x+10)/16),int((char.y+32)/16))=2 then char.sy=1:wlk=1
    if multikey(fb.sc_left) and char.sx > -char.ma then char.sx-=char.ac: char.d=-1
    if multikey(fb.sc_right) and char.sx < char.ma then char.sx+=char.ac: char.d=1
    if multikey(fb.sc_left) or multikey(fb.sc_right) then wlk=1
    if multikey(fb.sc_space) and spcbf=0 then
        spcbf=1:for x = 0 to 4:if frisbee(x).st=0 then:y=x:endif:next x
        frisbee(y).x=char.x:frisbee(y).y=char.y+8:frisbee(y).st=1:frisbee(y).d=char.d
    elseif not multikey(fb.sc_space) then:spcbf=0
    endif
    if multikey(fb.sc_escape) then end
    'sleep tim
    cycle-=1
    old = timer
    if char.hur>0 then
        select case char.d
        case -1: char.d=0
        case 0: char.d=-1
        case 1: char.d=2
        case 2: char.d=1
        end select
    endif
    do until timer >= old + 0.015
    loop
loop

death:
char.sy=-3
do until char.y>=241
    screenlock
    for y=fix(char.y/16)-2 to fix(char.y/16)+3:for x=fix(char.x/16)-2 to fix(char.x/16)+2
        redraw x,y
    next x:next y
    drawtile char1.i(), char.x*scw, char.y*sch, scw, sch, char.d
    drawtile char3.i(), char.x*scw, (char.y+16)*sch, scw, sch, char.d
    screenunlock
    char.x+=char.sx:char.y+=char.sy
    char.sy+=grav
    'if char.sx>0 then char.sx-=char.da:if char.sx < char.da then char.sx = 0
    'if char.sx<0 then char.sx+=char.da:if char.sx > -char.da then char.sx = 0
    old = timer
    do until timer >= old + 0.015
    loop
loop
char.lf-=1
if char.lf=0 then end
goto loadup

sub drawtile (tile() as ubyte, x as double, y as double, w as double, h as double, d as integer)
    dim as integer n1,n2
    if d=1 then
        for n1 = 0 TO 15:for n2 = 0 to 15
            if not (tile(n2,n1,0) = 255 and tile(n2,n1,1) = 0 and tile(n2,n1,2) = 255) then
            line (x+(n2*w),y+(n1*h))-(x+(n2*w)+w-1,y+(n1*h)+h-1),rgb(tile(n2,n1,0),tile(n2,n1,1),tile(n2,n1,2)),BF:endif
        next n2:next n1
    elseif d=-1 then
        for n1 = 0 TO 15:for n2 = 0 to 15
            if not (tile(n2,n1,0) = 255 and tile(n2,n1,1) = 0 and tile(n2,n1,2) = 255) then
            line (x+((-n2+15)*w),y+(n1*h))-(x+((-n2+15)*w)+w-1,y+(n1*h)+h-1),rgb(tile(n2,n1,0),tile(n2,n1,1),tile(n2,n1,2)),BF:endif
        next n2:next n1
    endif
end sub

sub loadimage (file as string, b as integer, tile() as ubyte)
    dim as integer x, y, z=0
    z = b*768
    open file for binary access read as #1
        if eof(1) then
            print "Error loading file "+file
            print "Press any key to terminate"
            sleep
            end
        endif
        for y = 0 to 15:for x = 0 to 15:z+=1:get #1,z,tile(x,y,0):next x:next y
        for y = 0 to 15:for x = 0 to 15:z+=1:get #1,z,tile(x,y,1):next x:next y
        for y = 0 to 15:for x = 0 to 15:z+=1:get #1,z,tile(x,y,2):next x:next y
    close #1
end sub

sub loadmap (file as string)
    dim as integer x, y, z=0
    open file for binary access read as #1
        if eof(1) then
            print "Error loading file "+file
            print "Press any key to terminate"
            sleep
            end
        endif
        for y = 0 to 14:for x = 0 to 19:z+=1:get #1,z,map(x,y):next x:next y
        for y = 0 to 14:for x = 0 to 19:z+=1:get #1,z,colmap(x,y):next x:next y
    close #1
end sub

sub loadgmap (file as string)
    dim as integer x, y, z=0
    open file for binary access read as #1
        if eof(1) then
            print "Error loading file "+file
            print "Press any key to terminate"
            sleep
            end
        endif
        for y = 0 to 99:for x = 0 to 99:z+=1:get #1,z,gmap(x,y):next x:next y
    close #1
end sub

sub redraw (x as integer, y as integer)
    select case map(x,y)
    case 1:drawtile floor1.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 2:drawtile floor2.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 3:drawtile ladder.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 4:drawtile floor3.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 5:drawtile floor4.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 6:drawtile bg1.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 7:drawtile bg2.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 8:drawtile floor5.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 9:drawtile lava.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 10:drawtile rocks.i(), x*16*scw, y*16*sch, scw, sch, 1
    end select
    select case colmap(x,y)
    case 6:drawtile pizza.i(), x*16*scw, y*16*sch, scw, sch, 1
    case 7:drawtile coin.i(), x*16*scw, y*16*sch, scw, sch, 1
    end select
end sub
