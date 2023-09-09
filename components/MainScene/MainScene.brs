sub init()
    m.top.backgroundURI = "pkg:/images/background-controls.jpg"
    m.save_feed_url = m.top.FindNode("save_feed_url")  'Save url to registry
    m.get_channel_list = m.top.FindNode("get_channel_list") 'get url from registry and parse the feed
    m.get_channel_list.ObserveField("content", "SetContent") 'Is thre content parsed? If so, goto SetContent sub and dsipay list

    font  = CreateObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/cn.ttf"
    font.size=33
    m.list = m.top.FindNode("list")
    m.list.font=font
    m.list.focusedFont = font
    m.list.focusedFont.size = font.size+5
    m.list.sectionDividerFont = font
    m.list.sectionDividerFont.size = font.size-6


    ' m.list.focusedFont = font
    ' m.list.focusedFont.size = font.size+5
    
    m.list.ObserveField("itemSelected", "setChannel") 


    m.video = m.top.FindNode("Video")
    m.video.setFocus(true)
    ' m.video.font=font
    ' m.video.control = "play"
    ' m.video.focusedFont.size = font.size+5

    ' m.video = m.top.FindNode("Video")
    
    m.video.ObserveField("state", "checkState")
    
    showdialog()  'Force a keyboard dialog.  

  

End sub


' function CreateFont(fontUrl as String) as Object
'     fontRegistry = CreateObject("roFontRegistry")
'     fontRegistry.AddFont(fontUrl)
'     font = fontRegistry.GetFontByIndex(0) ' 获取添加的字体
'     return font
' end function

' **************************************************************

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    print ">>> 详细信息 >> OnkeyEvent" 
    print key;" (";press;")" 
    print ;" (";m.video.position;")" 
    if(press)'
        m.backPressed = 0
        if(key = "right")
            m.list.SetFocus(false)
            m.top.SetFocus(true)
            m.video.translation = [0, 0]
            m.video.width = 0
            m.video.height = 0
            
            result = true
        ' else if key = "fastforward"
        '     m.trickPlaySpeed++
        '     if m.trickPlaySpeed > 3
        '         m.trickPlaySpeed = 1
        '     end if
        ' else if key = "rewind"
        '     m.trickPlaySpeed--
        '     if m.trickPlaySpeed < -3
        '             m.trickPlaySpeed = -1
        '     end if
        else if(key = "left")
            m.list.SetFocus(true)
            m.video.translation = [800, 100]
            m.video.width = 1056
            m.video.height = 649
            result = true
        else if(key = "back")
            ' if m.backPressed = 0
            ' m.list.SetFocus(true)
            ' m.video.translation = [800, 100]
            ' m.video.width = 1056
            ' m.video.height = 649
            ' result = true
        else if key="up"
            m.video.trickplaybar.visible=TRUE
        else if key="down"
            m.video.trickplaybar.visible=FALSE
        else if key="play"
            print ;" (";m.video.state;")" 

            ' If m.video.trickplaybar.visible=FALSE
            '     m.video.trickplaybar.visible=TRUE
            if m.video.state="playing"
                m.video.control="pause"
                m.video.trickplaybar.visible=TRUE
            else
                m.video.control="resume"
                m.video.trickplaybar.visible=FALSE
            end if
        else if(key = "options")
            showdialog()
            result = true
        else if key = "fastforward"
            if (m.video.duration - m.video.position) > 60
                m.video.seek = m.video.position + 60
            end if
        else if key = "rewind"
            m.video.position = m.video.position - 30
            if m.video.position < 0 then m.video.position = 0
            m.video.seek = m.video.position
        else if key = "replay"
            m.video.position = m.video.position - 10
            if m.video.position < 0 then m.video.position = 0
            m.video.seek = m.video.position
        end if
    end if
    
    return result 
end function


sub checkState()
    state = m.video.state
    if(state = "error")
        m.top.dialog = CreateObject("roSGNode", "Dialog")
        m.top.dialog.title = "Error: " + str(m.video.errorCode)
        m.top.dialog.message = m.video.errorMsg
    end if
end sub

sub SetContent()    
    m.list.content = m.get_channel_list.content
    m.list.SetFocus(true)
end sub

sub setChannel()
	if m.list.content.getChild(0).getChild(0) = invalid
		content = m.list.content.getChild(m.list.itemSelected)
	else
		itemSelected = m.list.itemSelected
		for i = 0 to m.list.currFocusSection - 1
			itemSelected = itemSelected - m.list.content.getChild(i).getChildCount()
		end for
		content = m.list.content.getChild(m.list.currFocusSection).getChild(itemSelected)
	end if
    print " (";m.video;")"

    ' font  = CreateObject("roSGNode", "Font")
    ' font.uri = "pkg:/fonts/cn.ttf"
    ' font.size=33
    ' m.scr = m.video.FindNode("ProgressBar")
    print " (";m.video.content;")"

    ' m.scr.font=font
    ' m.list.focusedFont = font
    ' m.list.focusedFont.size = font.size+5


	'Probably would be good to make content = content.clone(true) but for now it works like this
	content.streamFormat = "hls, mp4, mkv, mp3, avi, m4v, ts, mpeg-4, flv, vob, ogg, ogv, webm, mov, wmv, asf, amv, mpg, mp2, mpeg, mpe, mpv, mpeg2"
	if m.video.content <> invalid and m.video.content.url = content.url return

	content.HttpSendClientCertificates = true
	content.HttpCertificatesFile = "common:/certs/ca-bundle.crt"
	m.video.EnableCookies()
	m.video.SetCertificatesFile("common:/certs/ca-bundle.crt")
	m.video.InitClientCertificates()

	m.video.content = content

	m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
	m.video.trickplaybarvisibilityauto = false

	m.video.control = "play"
end sub


sub showdialog()
    PRINT ">>>  ENTERING KEYBOARD <<<"


    keyboarddialog = createObject("roSGNode", "StandardKeyboardDialog")
    keyboarddialog.backgroundUri = "pkg:/images/rsgde_bg_hd.jpg"
    keyboarddialog.title = "ENTER PLAYLIST HERE"

    keyboarddialog.buttons=["OK","Set back to Demo", "Save"]
    keyboarddialog.optionsDialog=true

    m.top.dialog = keyboarddialog
    m.top.dialog.text = m.global.feedurl
    ' m.top.dialog.keyboard.textEditBox.cursorPosition = len(m.global.feedurl)
    ' m.top.dialog.keyboard.textEditBox.maxTextLength = 300

    KeyboardDialog.observeFieldScoped("buttonSelected","onKeyPress")  'we observe button ok/cancel, if so goto to onKeyPress sub
end sub


sub onKeyPress()
    if m.top.dialog.buttonSelected = 0 ' OK
        url = m.top.dialog.text
        m.global.feedurl = url
        m.save_feed_url.control = "RUN"
        m.top.dialog.close = true
        m.get_channel_list.control = "RUN"
    else if m.top.dialog.buttonSelected = 1 ' Set back to Demo
        m.top.dialog.text = "http://192.168.10.38/suihua.m3u"
    else if m.top.dialog.buttonSelected = 2 ' Save
        m.global.feedurl = m.top.dialog.text
        m.save_feed_url.control = "RUN"
        '    m.top.dialog.visible ="false"
        '    m.top.unobserveField("buttonSelected")
    end if
end sub
