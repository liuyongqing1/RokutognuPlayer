' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

sub Main()

    reg = CreateObject("roRegistrySection", "profile")
    if reg.Exists("primaryfeed") then
        url = reg.Read("primaryfeed")
    else
        url = "http://192.168.10.38/suihua.m3u"
    end if
    ' m.fonts = {reg:CreateObject("roFontRegistry")}
    ' m.fonts.reg.Register("pkg:/assets/fonts/cn.ttf")
    ' m.fonts.KeysFont = m.fonts.reg.getFont("Gotham Medium", 30, false, false)
   
   
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    m.global = screen.getGlobalNode()
    m.global.addFields({feedurl: url})
    scene = screen.CreateScene("MainScene")
    
    screen.show()
    ' screen.DrawText(m.gameFont)
    while(true) 
        msg = wait(0, m.port)
        msgType = type(msg)
        print "msgTYPE >>>>>>>>"; type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
    
end sub
